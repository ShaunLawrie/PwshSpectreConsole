# General Instructions

- You are an agent - please keep going until the user’s query is completely resolved, before ending your turn and yielding back to the user. Only terminate your turn when you are sure that the problem is solved.
- If you are not sure about file content or codebase structure pertaining to the user’s request, use your tools to read files and gather the relevant information: do NOT guess or make up an answer.
- You MUST plan extensively before each function call, and reflect extensively on the outcomes of the previous function calls. DO NOT do this entire process by making function calls only, as this can impair your ability to solve the problem and think insightfully.
- You are a PowerShell expert.
- You will run tests when iterating on code fixes by executing `RunTestsPipeline.ps1` in the terminal.
- You will confirm docs can still be generated with `UpdateDocs.ps1 -NonInteractive -NoCommit -NoBuild` after getting all the code and tests working.
- You will not run `Build.ps1`, this are run automatically on the CI/CD pipeline.

# Adding New Features to the Module

- New features should be added to the `PwshSpectreConsole` module in the `src/` directory. The module is built using PowerShell and Spectre.Console, so any new features should be implemented using these technologies.
- Do not guess at how to format the code, check existing examples e.g. `PwshSpectreConsole/public/prompts/Read-SpectreSelection.ps1` to see how the code is structured and formatted.
- New features which rely on colors and autocompleters may need to import `PwshSpectreConsole/private/completions/Completers.psm1` or `PwshSpectreConsole/private/completions/Transformers.psm1` to get the correct color and autocompletion attributes.
- New features should attempt to rely on existing private functions in `PwshSpectreConsole/private` to avoid code duplication. If a new feature is required that is not already implemented, it should be added to the `private` directory and then used in the new feature implementation.
- New features should add examples.

# Documentation and Examples

- Do not edit the markdown or MDX files directly.
- All documentation is written inside the `.DESCRIPTION` and `.EXAMPLE` sections of the PowerShell comment based help in the `.ps1` files in the `PwshSpectreConsole/public/` directory.
- The `.SYNOPSIS` section is a summarised version of what is in the `.DESCRIPTION` section.
- Documentation in `PwshSpectreConsole.Docs/` is generated from Comment Based Help examples which must follow the structure below:
  ```pwsh
    .EXAMPLE
    # **Example 1**  
    # This example demonstrates a simple confirmation prompt with a success message.
    $answer = Read-SpectreConfirm -Message "Would you like to continue the preview installation of [#7693FF]PowerShell 7?[/]" `
                                  -ConfirmSuccess "Woohoo! The internet awaits your elite development contributions." `
                                  -ConfirmFailure "What kind of monster are you? How could you do this?"
    # Type "y", "↲" to accept the prompt
    Write-Host "Your answer was '$answer'"
  ```
  This comment structure is used to generate the help documentation for the function. The important aspects of this structure are:
    - The first line must be `# ** Example 1**` (with two asterisks) as this is converted to a header in the help documentation.
    - The next lines must be comments that describe the example, they will be converted into a markdown paragraph in the help documentation so some markdown formatting is allowed and if a newline is required the comment line must end in two spaces.
    - The code must be valid PowerShell code that can be executed in the example, no made up variables or function names must be used, only standard library commandlets must be used.
    - Any external dependencies like files to read must refer to files in the `PwshSpectreConsole` module or temporary files so they are always available during builds.
    - Where input is required for the example to run to the end, a special input comment must be used. This is done by using the `# Type "y", "↲" to accept the prompt` comment.
    - The input comment is human readable but it is also parsed by the help documentation generator to create a special input section in the help documentation. "Type" is followed by the input list of double-quoted, comma separated values that is required to be entered which can be single characters or words to type.
    - Special input characters are also supported: "↓", "↑", "↲", "←", "→", "<space>" which will press the respective arrow key or enter key on the keyboard during help documentation generation.
    - Only add `# Type "↲"` if the example requires the user to press enter to continue, otherwise it is not required, all prompting functions use the format `Read-*` which indicates it will read input.
- Adding new comment based help requires adding the new `.EXAMPLE` in the existing function docs.
- Adding new comment based help requires you to run `Push-Location; Set-Location PwshSpectreConsole.Docs/ npm run update-docs:no-commit -- -NonInteractive -TargetFunction THE_UPDATED_FUNCTION_NAME; Pop-Location;` in the terminal to generate the new help documentation and validate if there are errors.
- Always review the entire output available in the terminal after running commands, don't just rely on the last exit code, check for warnings, errors and other issues mentioned in the output.
- Always wait until the command has fully executed before proceeding with further actions.