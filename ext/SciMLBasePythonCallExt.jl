module SciMLBasePythonCallExt

using PythonCall: Py, PyList, pyimport, hasproperty, pyconvert, pyisinstance, pybuiltins
using SciMLBase: SciMLBase

# SciML uses a function's arity (number of arguments) to determine if it operates in place.
# PythonCall does not preserve arity, so we inspect Python functions to find their arity.
function SciMLBase.numargs(f::Py)
    inspect = pyimport("inspect")
    f2 = hasproperty(f, :py_func) ? f.py_func : f
    # if `f` is a bound method (i.e., `self.f`), `getfullargspec` includes
    # `self` in the `args` list. So, we subtract 1 in that case:
    pyconvert(Int, length(first(inspect.getfullargspec(f2))) - inspect.ismethod(f2))
end

_pyconvert(x::Py) = pyisinstance(x, pybuiltins.list) ? [_pyconvert(x) for x in x] : pyconvert(Any, x)
_pyconvert(x::PyList) = [_pyconvert(x) for x in x]
_pyconvert(x) = x

SciMLBase.prepare_initial_state(u0::Union{Py, PyList}) = _pyconvert(u0)
SciMLBase.prepare_function(f::Py) = _pyconvert ∘ f

end
