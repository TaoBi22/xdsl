from io import StringIO
from xdsl.ir import Operation

from xdsl.printer import Printer
from xdsl.utils.diagnostic import Diagnostic


def assert_print_op(
    operation: Operation,
    expected: str,
    diagnostic: Diagnostic | None,
    print_generic_format: bool = False,
):
    """
    Utility function that helps to check the printing of an operation compared to
    some string

    Examples
    --------
    To check that an operation, namely Add prints as:

    expected = \

    builtin.module() {
    %0 : !i32 = arith.addi(%<UNKNOWN> : !i32, %<UNKNOWN> : !i32)
    -----------------------^^^^^^^^^^----------------------------------------------------------------
    | ERROR: SSAValue is not part of the IR, are you sure all operations are added before their uses?
    -------------------------------------------------------------------------------------------------
    ------------------------------------------^^^^^^^^^^---------------------------------------------
    | ERROR: SSAValue is not part of the IR, are you sure all operations are added before their uses?
    -------------------------------------------------------------------------------------------------
    %1 : !i32 = arith.addi(%0 : !i32, %0 : !i32)
    }


    we call:

    .. code-block:: python

        assert_print_op(add, expected)

    """

    file = StringIO("")
    if diagnostic is None:
        diagnostic = Diagnostic()
    printer = Printer(
        stream=file,
        print_generic_format=print_generic_format,
        diagnostic=diagnostic,
    )

    printer.print(operation)
    assert file.getvalue().strip() == expected.strip()
