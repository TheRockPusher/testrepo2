"""Main tests."""

from testrepo2.hello import main


def test_foo() -> None:
    """Main Test."""
    assert main() == "Hello"
