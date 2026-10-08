"""Publish a new release only when compiled PDFs differ from the latest release."""

import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile


FILES = (Path("dist/main.pdf"), Path("dist/main-thesis.pdf"))


def gh(*args, missing_ok=False):
    result = subprocess.run(["gh", *args], capture_output=True, text=True)
    if result.returncode:
        if missing_ok and "(HTTP 404)" in result.stderr:
            return None
        raise RuntimeError(result.stderr.strip() or "GitHub CLI request failed")
    return result.stdout


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def summary(message):
    print(message)
    if path := os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(path, "a") as output:
            output.write(message + "\n")


def main():
    repo = os.environ["GH_REPO"]
    sha = os.environ["GITHUB_SHA"]
    api = f"repos/{repo}"
    for file in FILES:
        if not file.read_bytes().startswith(b"%PDF-"):
            raise ValueError(f"Invalid PDF: {file}")

    # Queued or manually rerun old commits must not replace the current release.
    head = json.loads(gh("api", f"{api}/commits/main"))["sha"]
    if sha != head:
        summary("提交已被新的 main 提交替代，跳过发布。")
        return

    raw = gh("api", f"{api}/releases/latest", missing_ok=True)
    release = json.loads(raw) if raw is not None else None
    with tempfile.TemporaryDirectory() as temporary:
        temporary = Path(temporary)
        previous = temporary / "previous"
        previous.mkdir()
        if release:
            assets = {asset["name"] for asset in release["assets"]}
            for file in FILES:
                if file.name in assets:
                    gh("release", "download", release["tag_name"], "--pattern", file.name,
                       "--dir", str(previous))
            unchanged = all(
                (previous / file.name).is_file()
                and digest(previous / file.name) == digest(file)
                for file in FILES
            )
            if unchanged:
                summary("两个 PDF 均与最新 Release 相同，未创建 Release 或标签。")
                return

        tag = f"pdf-{sha[:12]}-{os.environ['GITHUB_RUN_NUMBER']}.{os.environ['GITHUB_RUN_ATTEMPT']}"
        notes = temporary / "notes.md"
        notes.write_text(
            f"自动构建的毕业设计与毕业论文示例。\n\n"
            f"源码：[`{sha[:12]}`](https://github.com/{repo}/commit/{sha})\n\n"
            f"Typst：{os.environ['TYPST_VERSION']}；字体：macOS 指定家族。\n\n"
            + "\n".join(f"- `{file.name}` SHA-256：`{digest(file)}`" for file in FILES)
            + "\n",
            encoding="utf-8",
        )
        gh("release", "create", tag, "--target", sha, "--draft",
           "--title", f"PDF 示例 · {sha[:12]}", "--notes-file", str(notes))

        gh("release", "upload", tag, *(str(file) for file in FILES))
        # Confirm both uploads before publishing; previous releases are untouched.
        uploaded = temporary / "uploaded"
        uploaded.mkdir()
        for file in FILES:
            gh("release", "download", tag, "--pattern", file.name, "--dir", str(uploaded))
            if digest(uploaded / file.name) != digest(file):
                raise RuntimeError(f"Uploaded PDF checksum mismatch: {file.name}")
        gh("release", "edit", tag, "--draft=false", "--latest")
        summary(f"已发布新的 [PDF Release](https://github.com/{repo}/releases/tag/{tag})，保留历史版本。")


if __name__ == "__main__":
    main()
