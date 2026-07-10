"""Shared validation helper for diff and cmp rules."""

def validate(ctx, input_file, valid_output_path, error_message):
    valid_file = ctx.actions.declare_file(valid_output_path)
    emit_xml = ctx.file._emit_test_xml
    validate_script = ctx.file._validate_script

    ctx.actions.run_shell(
        inputs = [
            input_file,
            emit_xml,
            validate_script,
        ],
        outputs = [valid_file],
        env = {
            "ERROR_MESSAGE": error_message,
        },
        command = """\
"{validate_script}" "{input}" "{valid}" "{emit_xml}"
""".format(
            validate_script = validate_script.path,
            input = input_file.path,
            valid = valid_file.path,
            emit_xml = emit_xml.path,
        ),
    )
    return valid_file
