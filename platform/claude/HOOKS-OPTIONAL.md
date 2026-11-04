# Optional Claude Code UserPromptSubmit hook

The global `CLAUDE.md` policy is the recommended default. If you want a prompt-time reminder on every submitted prompt, merge `optional-settings-hook.json` into your existing `$HOME\.claude\settings.json`.

Do not overwrite your existing settings file. Merge the `hooks.UserPromptSubmit` array with existing hooks. The command emits a short policy reminder; it does not scan code or block actions. Review the command path before enabling it. Claude Code hook behavior and schema can evolve; verify against current official Claude Code hooks documentation for your installed version.

A hook reminder is not a security enforcement control. Use CI/CD gates and repository protections for enforcement.
