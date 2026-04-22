# .dotfiles

用 [GNU Stow](https://www.gnu.org/software/stow/) 管理個人設定檔的 repository。

## 原理

Stow 的核心概念是「symlink farm」：把真正的設定檔放在這個 repo 裡，然後在家目錄 `~/` 建立 symlink 指回來。這樣設定檔就可以用 git 做版本控制，同時各個工具又能正常讀取到它們。

```
~/.dotfiles/        ← 這個 repo（真正的檔案）
    .zshrc
    .emacs.d/
        init.el

~/                  ← 家目錄（symlinks）
    .zshrc       →  ~/.dotfiles/.zshrc
    .emacs.d/
        init.el  →  ~/.dotfiles/.emacs.d/init.el
```

## 常用指令

```bash
# 切到這個 repo 的目錄
cd ~/.dotfiles

# 建立所有 symlinks（初次設定或新增檔案後執行）
stow .

# 移除所有 symlinks
stow -D .

# 預覽會建立哪些 symlinks，不實際執行
stow -n -v .
```

## 目前管理的設定

| 檔案 | 用途 |
|---|---|
| `.zshrc` | Zsh shell 設定 |
| `.emacs.d/init.el` | Emacs 設定 |

## 注意事項

- `.stow-local-ignore` 列出不需要 symlink 到家目錄的檔案
- `.gitignore` 列出不需要 commit 的資料夾（套件、快取、執行期資料等）
- 如果家目錄已有同名的實體檔案（非 symlink），`stow` 會報錯，需要先手動移除或備份
