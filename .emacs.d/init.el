;;; -*- lexical-binding: t; -*-
;; 啟用詞法綁定（Lexical Binding）
;; 使 Elisp 程式碼執行速度更快，特別是在遞迴和高階函數的情況下
;; Emacs 29+ 推薦的做法

;; ============================================================================
;; § macOS 鍵盤修飾符設定
;; ============================================================================
;; 將 macOS 鍵盤的修飾符映射到 Emacs 的按鍵修飾符
;; - Command (⌘) → Meta (Alt)：用於文字編輯和導航快捷鍵
;; - Option (⌥) → Super (Windows 鍵)：用於應用級快捷鍵
;; 優勢：適應 Mac 使用者的按鍵習慣，避免頻繁使用物理 Alt 鍵
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta
        mac-option-modifier 'super))

;; ============================================================================
;; § 快捷鍵交換：C-t ↔ C-x
;; ============================================================================
;; 將 Emacs 高頻使用的前綴鍵 C-x 與 C-t 互換
;; 原因：C-x 用於許多重要命令（C-x b = 切換緩衝區、C-x f = 開檔案等）
;;       改到 C-t 使其更容易按到，改善手指疲勞
;; 影響：此設定會影響所有以 C-x 開頭的命令組合
(global-set-key (kbd "C-t") nil)          ; 先解除 C-t 原有綁定（若有）

(define-key key-translation-map (kbd "C-t") (kbd "C-x"))
(define-key key-translation-map (kbd "C-x") (kbd "C-t"))

;; ============================================================================
;; § 自訂快捷鍵匯整
;; ============================================================================
;; 根據個人工作流最佳化的按鍵綁定
;; - M-* （Meta + 鍵）：高頻編輯和導航操作（Option/Alt）
;; - s-* （Super + 鍵）：應用級操作（macOS 的 Command 鍵）
;; 設計理念：讓最常用的編輯功能集中在鍵盤中心（home row），減少手指移動

;; ### 游標移動類快捷鍵 ###
;; 快速移動到行首、行尾、縮進位置
(global-set-key (kbd "M-a") 'move-beginning-of-line)
(global-set-key (kbd "M-e") 'move-end-of-line)
(global-set-key (kbd "M-i") 'back-to-indentation)

;; 段落級導航（比逐行移動更高效）
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)

;; 螢幕捲動（單頁面翻頁，比滑鼠滾輪更精確）
(global-set-key (kbd "M-N") 'scroll-up-command)
(global-set-key (kbd "M-P") 'scroll-down-command)

;; S-表達式導航（括號和語義結構）
;; 用於快速跳過程式碼的各種結構單位
(global-set-key (kbd "M-[") 'backward-sexp)
(global-set-key (kbd "M-]") 'forward-sexp)

;; 針對 Python 模式的特殊設定
;; Python 使用縮進而非括號來定義區塊，所以用 backward-list/forward-list
(with-eval-after-load 'python
  (define-key python-mode-map (kbd "M-[") 'backward-list)
  (define-key python-mode-map (kbd "M-]") 'forward-list))

;; ### 緩衝區和視窗管理 ###
;; 快速切換到上一個訪問的緩衝區
;; 用途：在兩個經常使用的檔案之間快速來回切換
(defun my-quick-switch-buffer ()
  "切換到上一個訪問的緩衝區。"
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) t)))

(global-set-key (kbd "s-f") 'my-quick-switch-buffer)

;; 切換到下一個視窗（循環切換）
(global-set-key (kbd "M-w") 'other-window)

;; ### 編輯類快捷鍵 ###
;; 複製和貼上（同時支援 Meta 和 Super，適應不同鍵盤習慣）
(global-set-key (kbd "M-c") 'kill-ring-save)
(global-set-key (kbd "M-v") 'yank)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "M-y") 'yank-pop)  ; 循環顯示之前複製的內容

;; 行編輯操作
(global-set-key (kbd "M-k") 'kill-line)                    ; 刪除至行尾
(global-set-key (kbd "M-j") (lambda () (interactive) (join-line -1)))  ; 合併行

;; 單字大寫和撤銷操作
(global-set-key (kbd "M-t") 'capitalize-word)
(global-set-key (kbd "M-z") 'undo)

;; 程式碼補完快捷觸發
(global-set-key (kbd "M-.") 'completion-at-point)

;; ============================================================================
;; § Homebrew 路徑設定（macOS）
;; ============================================================================
;; 添加 Apple Silicon Mac 的 Homebrew 預設安裝位置到 Emacs 可執行路徑
;; 用途：使 Emacs 能調用 Homebrew 安裝的外部工具
;; 例如：language servers (LSP)、編譯器、linter 等
(add-to-list 'exec-path "/opt/homebrew/bin")

;; ============================================================================
;; § 套件管理系統設定（Emacs 30 最佳實踐）
;; ============================================================================
;; 設定 Emacs 套件的來源和優先級

;; 三個主要套件來源的說明：
;; - gnu (優先級 90)：官方 GNU Emacs 套件，最穩定但數量少
;; - nongnu (優先級 80)：非官方但經審核的套件，品質有保障
;; - melpa (優先級 60)：社群貢獻最多的套件來源，套件最全、更新最快
;;     但品質不如 gnu 和 nongnu 穩定
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))

(setq package-archive-priorities
      '(("gnu"    . 90)
        ("nongnu" . 80)
        ("melpa"  . 60)))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; 使用 use-package 進行宣告式套件管理（Emacs 29+ 內建）
;; use-package 的優點：
;; - 設定結構清晰，便於理解和維護
;; - 支援延遲加載 (:defer/:demand)，加快 Emacs 啟動速度
;; - 自動處理套件依賴關係
;; - :bind 和 :hook 簡化快捷鍵和事件綁定
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)  ; 自動安裝缺失的套件
(setq use-package-verbose t)        ; 顯示載入訊息以利除錯

;; ============================================================================
;; § no-littering：自動整理 Emacs 生成的檔案
;; ============================================================================
;; 功能：避免 .emacs.d 目錄被 Emacs 執行時產生的檔案污染
;; 優勢：
;; - 設定倉庫（git）更乾淨，易於版本控制
;; - 將設定檔（custom.el）和執行檔（快取、備份）分離
;; - 自動管理檔案位置，無需手動操作
;;
;; 目錄結構：
;; - etc/ ：設定檔目錄（custom.el、主題備份等）
;; - var/ ：執行檔目錄（快取、歷史、備份等）
(use-package no-littering
  :demand t  ; 立即加載，優先級最高

  :config
  ;; 將自訂設定檔移到 etc/ 目錄
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  ;; 若自訂檔已存在，載入它
  (when (file-exists-p custom-file)
    (load custom-file 'noerror 'nomessage))
  ;; 將主題相關備份也整理到隱藏目錄
  (no-littering-theme-backups)
  ;; 讓原生編譯快取（eln-cache）也被 no-littering 接管
  (when (boundp 'native-comp-eln-load-path)
    (setq native-comp-eln-load-path
          (list (no-littering-expand-var-file-name "eln-cache/")))))

;; ============================================================================
;; § gcmh：激進的垃圾回收管理
;; ============================================================================
;; 功能：更激進的垃圾回收（GC）策略，最佳化 Emacs 整體性能
;; 為何需要：
;; - Emacs 預設 GC 策略在大檔案操作時易造成卡頓
;; - 特別是編寫大型原始碼檔案、處理長行時明顯
;; - 此套件主動在空閒時清理，而非被動等待卡頓
;;
;; 參數說明：
;; - gcmh-high-cons-threshold：非空閒時 GC 上限（100 MB）
;; - gcmh-idle-delay：空閒多久後觸發 GC（5 秒）
(use-package gcmh
  :demand t

  :init
  ;; Apple Silicon 建議值：根據機器記憶體調整（100–500 MB）
  (setq gcmh-high-cons-threshold (* 100 1024 1024))  ; 100 MB，非空閒時上限
  (setq gcmh-idle-delay 5)                           ; 空閒 5 秒後主動清理

  :config
  (gcmh-mode 1))

;; ============================================================================
;; § UI 主題和外觀設定
;; ============================================================================

;; --- cyberpunk-theme：深色系主題 ---
;; 選擇理由：
;; - 2026 年仍然是 Emacs 社群中流行的深色主題
;; - 配色搭配精心設計，易於眼睛適應
;; - 對各類編程模式的語法高亮支援完善
(use-package cyberpunk-theme
  :demand t

  :init
  ;; 先停用所有既有主題，避免顏色衝突
  (mapc #'disable-theme custom-enabled-themes)

  ;; 載入並啟用 cyberpunk 主題
  (load-theme 'cyberpunk t))

;; --- GUI 元件管理 ---
;; 停用不必要的 GUI 元件，簡化介面並節省螢幕空間
;; - menu-bar：頂部功能表（可用 M-x 替代）
;; - tool-bar：工具列圖示（鍵盤快捷鍵更高效）
;; - scroll-bar：捲軸（鍵盤導航或 C-l 居中更快）
(menu-bar-mode   -1)
(tool-bar-mode   -1)
(scroll-bar-mode -1)

;; --- 字型設定 ---
;; 設定預設字型與大小（所有模式的基礎字型）
;; 使用 Nerd Font Mono 提供圖示支援和更好的排版
(set-face-attribute 'default nil
  :family "DejaVuSansM Nerd Font Mono"
  :height 180  ; 180/10 = 18pt
  :weight 'normal
  :width 'normal)

;; 固定寬度字型（fixed-pitch）設定
;; 用途：程式碼、終端等需要對齊的內容
(set-face-attribute 'fixed-pitch nil
  :family "DejaVuSansM Nerd Font Mono"
  :height 1.0)  ; 相對於 default 的比例

;; 可變寬度字型（variable-pitch）設定
;; 用途：某些模式（org-mode 標題、markdown 等）會使用此字型
(set-face-attribute 'variable-pitch nil
  :family "DejaVu Serif"
  :height 1.1)

;; ============================================================================
;; § which-key：快捷鍵提示面板
;; ============================================================================
;; 功能：按下快捷鍵前綴（如 C-x、C-c）後，顯示後續可用的按鍵選項
;; 用途：
;; - 學習和發現快捷鍵組合
;; - 對 Emacs 新手特別有幫助
;; - 即使是老手也能快速記起不常用的命令
(use-package which-key
  :demand t

  :custom
  ;; 按鍵後多久顯示提示（0.6 秒，可調 0.3–1.0）
  (which-key-idle-delay 0.6)
  ;; 顯示順序：先本地按鍵綁定，再全局按鍵
  (which-key-sort-order 'which-key-local-then-key-order)

  :config
  (which-key-mode 1))

;; ============================================================================
;; § avy：快速游標導航
;; ============================================================================
;; 功能：不用搜尋，直接跳轉到可見的字元或行
;; 工作方式：按快捷鍵後輸入目標字元，Emacs 會標註所有匹配位置，
;;           按標籤跳到指定位置（通常 1–2 按鍵完成）
;; 優勢：比 Ctrl+F 查找更快、更精確
;;
;; 快捷鍵：
;; - M-o：跳轉到字元
(use-package avy
  :bind
  ("M-o" . avy-goto-char)
  :custom (avy-background t :style 'at-full))

;; ============================================================================
;; § hl-line：高亮當前行
;; ============================================================================
;; 功能：視覺化標記游標所在的行，便於追蹤游標位置
;; 特別有用於：編寫程式碼時追蹤游標、螢幕滾動時定位
(use-package hl-line
  :hook
  ((after-init . global-hl-line-mode))  ; 延遲到啟動完成後開啟，避免啟動閃爍

  :config
  ;; 僅在圖形模式下啟用（終端機模式通常不需要）
  (when (display-graphic-p)
    (global-hl-line-mode 1))
  ;; 自訂高亮樣式（與 cyberpunk-theme 搭配時特別有用）
  (custom-set-faces
   '(hl-line ((t (:background "#1e1e2e" :extend t)))))  ; 深色背景 + 全寬延伸
  )

;; ============================================================================
;; § column-number-mode：顯示欄位號碼
;; ============================================================================
;; 功能：在狀態欄顯示游標所在的列號（編寫程式碼時有用）
;; 用途：精確定位程式碼位置，特別是需要遵循 line length 限制時
(column-number-mode t)

;; ============================================================================
;; § helpful：增強幫助系統
;; ============================================================================
;; 功能：比內建 describe-* 更詳細的文檔和原始碼檢視
;; 優勢：
;; - 顯示函數參數、回傳值等詳細資訊
;; - 提供原始碼連結，方便追蹤實作
;; - 改進的使用者介面，更易閱讀
;;
;; 替換的命令：
;; - C-h f：查看函數（helpful-callable）
;; - C-h v：查看變數（helpful-variable）
;; - C-h k：查看按鍵綁定（helpful-key）
;; - C-h c：查看命令（helpful-command）
(use-package helpful
  :demand t

  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key]      . helpful-key)
  ([remap describe-command]  . helpful-command))

;; ============================================================================
;; § savehist：保存 minibuffer 歷史
;; ============================================================================
;; 功能：保存 minibuffer 的輸入歷史記錄（搜尋、命令等）
;; 用途：重啟 Emacs 後仍能回憶之前的輸入歷史
;; 優勢：提升工作流效率，避免重複輸入相同的命令
(use-package savehist
  :init
  (savehist-mode 1))

;; ============================================================================
;; § save-place-mode：保存檔案中的游標位置
;; ============================================================================
;; 功能：記錄每個檔案上次編輯時的游標位置
;; 用途：重新打開檔案時自動回到上次編輯的位置
;; 優勢：
;; - 提升工作效率（不需要手動捲動到編輯位置）
;; - 適合編輯大型檔案
;; - Emacs 內建功能，無需額外套件
;;
;; 使用方式：
;; - 自動啟用，無需手動設定
;; - 位置信息儲存在 .emacs.d/places（由 no-littering 管理）
(save-place-mode 1)

;; ============================================================================
;; § vertico：高性能 minibuffer 補完框架
;; ============================================================================
;; 功能：現代化的 minibuffer 補完系統，比預設補完更快、更靈活
;; 優勢：
;; - 垂直列表顯示補完選項，易於閱讀
;; - 支援多種導航方式（上下箭頭、C-j/C-k）
;; - 與 orderless、marginalia 等套件完美整合
;; - 啟動快速，對 Emacs 性能影響最小
;;
;; 核心特性：
;; - vertico-cycle：列表循環（到底下後回到頂部）
;; - vertico-resize：動態調整 minibuffer 高度
;; - vertico-count：一次顯示的候選數量
(use-package vertico
  :demand t

  :init
  (vertico-mode)

  :custom
  (vertico-cycle t)             ; 列表循環
  (vertico-resize t)            ; 動態調整 minibuffer 高度
  (vertico-count 15)            ; 一次顯示的候選數量（可依螢幕大小調整 10–20）

  :bind
  (:map vertico-map
        ("C-j" . vertico-next)                       ; 下一個選項
        ("C-k" . vertico-previous)                   ; 上一個選項
        ("C-l" . vertico-insert)                     ; 插入目前選項但不結束補完
        ("RET" . vertico-directory-enter)            ; 進入目錄（檔案補完時常用）
        ("DEL" . vertico-directory-delete-char))     ; 刪除一個字元

  :config
  ;; 搭配 savehist 保存補完歷史
  (add-to-list 'savehist-additional-variables 'vertico-sort-function)

  ;; 讓 vertico 在某些情境下使用不同顯示方式
  (add-hook 'minibuffer-setup-hook
            (lambda ()
              (setq completion-in-region-function
                    #'consult-completion-in-region))))

;; ============================================================================
;; § orderless：模糊補完匹配風格
;; ============================================================================
;; 功能：空格分隔的多詞模糊匹配，提供靈活的補完體驗
;; 工作方式：輸入的空格將被視為「任意字元」，因此 "foo bar" 能匹配 "foobar"
;; 優勢：
;; - 比預設的前綴或子字元串匹配更靈活
;; - 搜尋檔案和命令時更直觀
;; - 支援模式匹配（如 "*.el" 搜尋 Elisp 檔案）
;;
;; 設定說明：
;; - completion-styles：使用 orderless 搭配 basic 風格
;; - completion-category-overrides：檔案搜尋使用 basic 和 partial-completion
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles basic partial-completion)))))

;; ============================================================================
;; § marginalia：補完邊界註釋
;; ============================================================================
;; 功能：在補完列表旁顯示額外資訊（變數類型、函數用途等）
;; 優勢：
;; - 快速瞭解補完選項的含義
;; - 減少需要查詢文檔的次數
;; - 特別對變數和函數補完有幫助
;;
;; 註釋內容包括：
;; - 函數：簡要說明和參數資訊
;; - 變數：類型和目前值
;; - 命令：用途說明
;; - 檔案：檔案大小、修改時間等
(use-package marginalia
  :after vertico

  :init
  (marginalia-mode)

  :custom
  (marginalia-align 'right)
  ;; 關閉相對時間（讓註解更簡潔）
  (marginalia-max-relative-age 0))

;; ============================================================================
;; § consult：高級搜尋和導航工具集
;; ============================================================================
;; 功能：提供多種高級搜尋和導航命令，增強 minibuffer 補完體驗
;; 主要用途：
;; - consult-grep：在檔案中搜尋文字（替代 grep）
;; - consult-buffer：增強的緩衝區切換
;; - consult-line：在當前緩衝區搜尋行
;; - consult-goto-line：跳轉到指定行號
;; 優勢：
;; - 整合 vertico 提供即時預覽
;; - 支援多種搜尋方式
;; - 搜尋結果實時更新
(use-package consult
  :after
  (vertico marginalia)

  :custom
  ;; 輸入 0.3 秒後進行預覽，避免過於頻繁的更新
  (consult-preview-key '(:debounce 0.3 any))
  ;; 按 ? 切換搜尋類別
  (consult-narrow-key "?")

  :config
  ;; 啟用點擊預覽（在 vertico 列表中點擊項目時預覽）
  (add-hook 'completion-list-mode-hook #'consult-preview-at-point-mode))

;; ============================================================================
;; § expand-region：智能區域選擇
;; ============================================================================
;; 功能：逐步擴展選區，從字到詞、句、段等
;; 工作方式：每按一次快捷鍵就擴大一層選區，快速選擇程式碼區塊
;; 優勢：
;; - 比手動拖曳或 Shift+方向鍵 快得多
;; - 理解程式碼結構，進行語義級選擇
;; - 支援多種程式語言
;;
;; 快捷鍵：
;; - s-h：擴展選區（expand）
;; - s-i：選擇引號內的內容
;; - s-o：選擇引號外的內容
(use-package expand-region
  :bind (("s-h" . er/expand-region)
	 ("s-i" . er/mark-inside-quotes)
	 ("s-o" . er/mark-outside-quotes)))

;; ============================================================================
;; § multiple-cursors：多游標編輯
;; ============================================================================
;; 功能：同時在多個位置編輯，進行批量修改
;; 工作方式：標記多個位置，同步進行文字輸入或編輯
;; 用途：
;; - 批量修改相同文字
;; - 在多個位置進行平行編輯
;; - 快速重構程式碼中的重複部分
;;
;; 快捷鍵：
;; - s-t：標記下一個相同的文字（mark-next-like-this）
;; - s-r：標記上一個相同的文字（mark-previous-like-this）
(use-package multiple-cursors
  :bind (("s-t" . mc/mark-next-like-this)
	 ("s-r" . mc/mark-previous-like-this)))

;; ============================================================================
;; § nerd-icons：現代化圖示系統
;; ============================================================================
;; 功能：為 Emacs 提供 Nerd Font 圖示支援
;; 為何選擇 nerd-icons：
;; - 2026 年 Emacs 生態的主流圖示方案（替代老舊的 all-the-icons）
;; - 支援最新的 Nerd Font 字體，圖示庫龐大
;; - 效能優化，不會拖累 Emacs 啟動速度
;;
;; 安裝步驟：
;; 1. 執行 M-x nerd-icons-install-fonts 安裝 Nerd 字體
;; 2. 重啟 Emacs 使字體生效
;;
;; 注意：需要終端機和 Emacs 都支援 Nerd Font 才能正確顯示
(use-package nerd-icons
  :demand t
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono"))

;; nerd-icons-dired：在檔案管理器中顯示檔案類型圖示
;; 功能：為不同的檔案類型顯示相應的圖示，改進視覺識別
;; 用途：快速識別檔案類型（資料夾、圖片、程式碼等）
(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

;; nerd-icons-completion：在補完列表中顯示圖示
;; 功能：整合 marginalia，在補完時也顯示圖示
;; 用途：視覺化增強，更直觀的補完體驗
(use-package nerd-icons-completion
  :after marginalia
  :hook
  (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config
  (nerd-icons-completion-mode))

;; ============================================================================
;; § doom-modeline：美觀高級的狀態欄
;; ============================================================================
;; 功能：以 Doom Emacs 風格設計的現代化 modeline（狀態欄）
;; 優勢：
;; - 視覺上更美觀，資訊顯示更清晰
;; - 整合多種資訊（檔案狀態、VCS、主要模式等）
;; - 支援圖示顯示
;; - 效能優化，不會拖累 Emacs
;;
;; 設定說明：
;; - doom-modeline-enable-word-count：啟用字數統計
;; - doom-modeline-buffer-encoding：關閉編碼顯示（保持簡潔）
;; - doom-modeline-env-version：關閉環境版本資訊
;; - doom-modeline-icon：啟用圖示顯示
;; - doom-modeline-minor-modes：隱藏次要模式（避免過於繁雜）
(use-package doom-modeline
  :init (doom-modeline-mode 1)

  :custom
  (doom-modeline-enable-word-count t)               ; 字數統計
  (doom-modeline-buffer-encoding nil)               ; 關閉編碼顯示
  (doom-modeline-env-version nil)                   ; 關閉環境版本
  (vc-display-status nil)			    ; 關閉 VCS 狀態
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-icon t)                            ; 啟用圖示
  (doom-modeline-minor-modes nil)                   ; 隱藏次要模式

  :config
  ;; 強制忽略 VCS 文字更新（提升性能）
  (advice-add #'doom-modeline-update-vcs-text :override #'ignore))

;; ============================================================================
;; § perspective：工作空間和視角管理
;; ============================================================================
;; 功能：為不同的專案建立獨立的緩衝區空間，實現工作空間隔離
;; 用途：
;; - 管理多個專案，每個專案有獨立的緩衝區集合
;; - 避免在不同專案間切換時產生的緩衝區混亂
;; - 快速切換工作上下文
;;
;; 核心概念：
;; - 每個「視角（perspective）」是一個獨立的工作空間
;; - 各視角有各自的緩衝區集合、視窗配置等
;; - 視角狀態會自動儲存和恢復
;;
;; 設定說明：
;; - persp-sort：按最近存取時間排序視角
;; - persp-mode-prefix-key：視角管理命令的前綴鍵（C-c p）
;; - persp-state-default-file：視角狀態檔案位置
(use-package perspective
  :demand t

  :init
  (persp-mode)

  :custom
  ;; 按最近存取時間排序視角
  (persp-sort 'access)
  ;; 視角管理命令的前綴鍵
  (persp-mode-prefix-key (kbd "C-c p"))
  ;; 視角狀態檔案位置（由 no-littering 管理）
  (persp-state-default-file
   (no-littering-expand-var-file-name "persp-state"))

  :config
  ;; 自動儲存視角狀態（關閉 Emacs 時）
  (add-hook 'kill-emacs-hook #'persp-state-save))

;; ============================================================================
;; § anzu：查詢和取代的增強顯示
;; ============================================================================
;; 功能：在進行查詢和取代時，顯示匹配數量和當前位置
;; 優勢：
;; - 使批量取代更安全透明（能看到總共有多少個匹配）
;; - 顯示當前進度（正在處理第幾個匹配）
;; - 整合 doom-modeline，狀態欄顯示清晰
;;
;; 工作方式：
;; - M-% 或 C-M-% 開始取代時，顯示匹配數
;; - 逐一確認或批量替換時可看到進度
(use-package anzu
  :init
  (global-anzu-mode +1)

  :custom
  ;; 取代提示的格式（"old → new"）
  (anzu-replace-to-string-separator " → ")

  :config
  ;; 讓 doom-modeline 處理狀態列顯示，避免重複
  (setq anzu-cons-mode-line-p nil))

;; ============================================================================
;; § ws-butler：自動清理空白字元
;; ============================================================================
;; 功能：自動清理行尾和檔案末尾的多餘空白
;; 優勢：
;; - 保持程式碼乾淨
;; - 避免不必要的 whitespace 變更被提交到 git
;; - 自動執行，無需手動操作
;;
;; 應用範圍：
;; - prog-mode：所有程式語言的編輯模式
;; - text-mode：純文字和標記語言
(use-package ws-butler
  :hook
  ((prog-mode text-mode) . ws-butler-mode)

  :custom
  ;; 檔案結尾保留最多一行空行（避免完全刪除所有空行）
  (ws-butler-trim-eob-lines t))

;; ============================================================================
;; § electric-pair-mode：自動配對括號和引號
;; ============================================================================
;; 功能：在輸入開括號或引號時，自動插入相應的閉合符號
;; 優勢：
;; - 避免括號不配對的錯誤
;; - 加快括號和引號輸入速度
;; - 提高編寫程式碼的效率
;;
;; 智能配置：
;; - 在不同語言中有不同的行為
;; - Python f-strings（f"..."）和原始字符串（r"..."）前會禁用自動配對
;; - Elisp 中 'symbol 和 #'function 前也會禁用，避免干擾
(electric-pair-mode 1)

;; 自訂自動配對規則
;; 避免在特定情況下自動插入配對符號，防止干擾編寫
(setq electric-pair-inhibit-predicate
      (lambda (char)
        (or
         ;; Python f/r/b-string 前置
         ;; 當在 Python 中於 f、r 或 b 字符後面時，不自動配對引號
         ;; （因為 f"..."、r"..."、b"..." 是特殊語法）
         (and (eq major-mode 'python-mode)
              (looking-back "[frb]?" 1)
              (memq char '(?\" ?\'))
              (not (looking-back "[\"']" 1)))
         ;; Elisp 'symbol 或 #'function 前置
         ;; 在 Elisp 中 ' 和 # 後面是特殊語法，不自動配對
         (and (memq major-mode '(emacs-lisp-mode lisp-mode))
              (looking-back "['#]" 1)
              (memq char '(?\' ?\")))
         ;; 其他情況使用預設規則
         (electric-pair-default-inhibit char))))

;; ============================================================================
;; § vterm：高效的 Emacs 終端機模擬器
;; ============================================================================
;; 功能：在 Emacs 內嵌入全功能的終端機環境
;; 優勢：
;; - 完整的終端機功能（支援彩色、滑鼠、TUI 應用）
;; - 比 shell-mode 和 term-mode 性能更好
;; - 支援執行任何命令行工具（vim、fzf、nnn 等）
;; - 可在 Emacs 和終端機模式間快速切換
;;
;; 快捷鍵：
;; - M-a/M-e：跳轉到提示符行的開始/結尾
;; - M-p/M-n：上/下一個提示符
;; - M-v：貼上（在終端機中）
;; - M-C：進入/退出 copy mode（可複製終端輸出）
;; - C-u：清除當前行輸入
(use-package vterm
  :commands vterm

  :bind
  (:map vterm-mode-map
        ("M-a" . vterm-beginning-of-line)
        ("M-e" . move-end-of-line)
        ("M-p" . vterm-previous-prompt)
        ("M-n" . vterm-next-prompt)
        ("M-v" . yank)
        ("M-C" . vterm-copy-mode)
        ("C-u" . vterm-send-C-u))
  (:map vterm-copy-mode-map
        ("M-C" . vterm-copy-mode))

  :config
  ;; 設定滾回緩衝區大小（更多歷史記錄）
  (setq vterm-max-scrollback 10000)
  ;; 取消 M-w 的綁定，避免與全域 other-window 衝突
  (unbind-key "M-w" vterm-mode-map))

;; ============================================================================
;; § undo-fu：輕量級撤銷和重做支援
;; ============================================================================
;; 功能：提供更好的 redo 支援，改進 Emacs 預設的撤銷系統
;; 優勢：
;; - 保留完整的撤銷樹結構（可以回溯任何狀態）
;; - 提供清晰的 redo 機制（M-Z）
;; - 輕量級，不會影響性能
;; - 支援重複 redo（按住快捷鍵連續重做）
;;
;; 快捷鍵：
;; - M-z：撤銷（內建）
;; - M-Z：重做（undo-fu 提供）
(use-package undo-fu
  :bind ("M-Z" . undo-fu-only-redo)

  :custom
  ;; 允許重複 redo（按住 M-Z 連續重做）
  (undo-fu-allow-redo t))

;; ============================================================================
;; § Dired 和檔案刪除設定（macOS 專屬）
;; ============================================================================
;; 功能：將檔案系統刪除操作改為移到系統垃圾筒，提供安全性
;; 優勢：
;; - 誤刪檔案可以從垃圾筒恢復
;; - 整合 macOS 原生垃圾筒機制
;; - 避免永久刪除的風險
;;
;; 設定說明：
;; - delete-by-moving-to-trash：刪除時移到垃圾筒而非永久刪除
;; - trash-directory：指定 macOS 系統垃圾筒位置
(when (eq system-type 'darwin)
  (setq delete-by-moving-to-trash t)         ; 刪除時移到 Trash
  (setq trash-directory (expand-file-name "~/.Trash")))  ; 明確 Trash 位置

;; ============================================================================
;; § 自訂輔助函數
;; ============================================================================
;; 本區塊包含各種提高工作效率的自訂命令和函數
;; 這些函數主要用於視窗操作、緩衝區管理等日常工作

;; --- 視窗分割與導航 ---
;; 功能：分割視窗並自動移動到新視窗
;; 避免分割後還要手動切換視窗的額外操作
(defun split-window-down-and-move-there-dammit ()
  "向下分割視窗並移動到新視窗"
  (interactive)
  (split-window-below)
  (windmove-down))

(defun split-window-right-and-move-there-dammit ()
  "向右分割視窗並移動到新視窗"
  (interactive)
  (split-window-right)
  (windmove-right))

;; --- 緩衝區資訊複製 ---
;; 功能：快速複製當前緩衝區的各種資訊到剪貼板
;; 用途：便於在終端機或其他應用中參考檔案路徑或名稱

(defun my-buffer-name ()
  "複製當前緩衝區名稱到剪貼板"
  (interactive)
  (let ((n (buffer-name)))
    (kill-new n)
    (message n)))

(defun my-buffer-path ()
  "複製當前目錄路徑到剪貼板"
  (interactive)
  (let ((n default-directory))
    (kill-new n)
    (message n)))

(defun my-buffer-full-name ()
  "複製當前檔案完整路徑到剪貼板"
  (interactive)
  (let ((n (buffer-file-name)))
    (kill-new n)
    (message n)))

;; ============================================================================
;; § Leader Key 配置（Spacemacs 風格）
;; ============================================================================
;; 功能：使用 M-SPC 作為統一的命令前綴鍵，組織相關功能
;; 優勢：
;; - 統一的快捷鍵前綴，易於記憶
;; - 無需外部套件（general.el），使用 Emacs 內建方式
;; - 搭配 which-key 提供實時幫助提示
;; - 類似 Spacemacs/Vim leader key 的工作流
;;
;; 結構：M-SPC [分類] [功能]
;; 例如：M-SPC p t = perspective toggle、M-SPC h f = help function

;; 定義 leader key 前綴
(define-prefix-command 'my-leader-map)
(global-set-key (kbd "M-SPC") 'my-leader-map)

;; --- M-SPC p：Perspective（工作空間管理） ---
;; 快速切換不同的工作空間，隔離不同專案的緩衝區
(which-key-add-key-based-replacements
  "M-SPC p"   "perspective"
  "M-SPC p t" "switch perspective"
  "M-SPC p p" "last"
  "M-SPC p f" "switch buffer"
  "M-SPC p l" "load"
  "M-SPC p s" "save"
  "M-SPC p k" "kill"
  "M-SPC p m" "move buffer"
  "M-SPC p r" "rename"
  )
(define-key my-leader-map (kbd "p t") 'persp-switch)
(define-key my-leader-map (kbd "p p") 'persp-switch-last)
(define-key my-leader-map (kbd "p f") 'persp-switch-to-buffer*)
(define-key my-leader-map (kbd "p l") 'persp-state-load)
(define-key my-leader-map (kbd "p s") 'persp-state-save)
(define-key my-leader-map (kbd "p k") 'persp-kill)
(define-key my-leader-map (kbd "p m") 'persp-set-buffer)
(define-key my-leader-map (kbd "p r") 'persp-rename)

;; --- M-SPC h：Help（幫助系統） ---
;; 快速查詢函數、變數、按鍵綁定等文檔
(which-key-add-key-based-replacements
  "M-SPC h"   "help"
  "M-SPC h f" "function"
  "M-SPC h v" "variable"
  "M-SPC h k" "key"
  "M-SPC h m" "mode"
)
(define-key my-leader-map (kbd "h f") 'helpful-callable)
(define-key my-leader-map (kbd "h v") 'helpful-variable)
(define-key my-leader-map (kbd "h k") 'helpful-key)
(define-key my-leader-map (kbd "h m") 'describe-mode)

;; --- M-SPC f：File（檔案操作） ---
;; 打開檔案、搜尋專案檔案等文件操作
(which-key-add-key-based-replacements
  "M-SPC f"   "file"
  "M-SPC f o" "open"
  "M-SPC f w" "native open"
  "M-SPC f p" "open project file"
  )
(define-key my-leader-map (kbd "f o") 'find-file)
(define-key my-leader-map (kbd "f w") 'ns-open-file-using-panel)
(define-key my-leader-map (kbd "f p") 'project-find-file)

;; --- M-SPC m：Mark（多游標編輯） ---
;; 標記多個相似的文字或區域，進行批量編輯
(which-key-add-key-based-replacements
  "M-SPC m"   "mark"
  "M-SPC m e" "more like this"
  "M-SPC m l" "multiple edit"
  "M-SPC m g" "region"
  )
(define-key my-leader-map (kbd "m e") 'mc/mark-more-like-this-extended)
(define-key my-leader-map (kbd "m l") 'mc/edit-lines)
(define-key my-leader-map (kbd "m g") 'mc/mark-all-in-region)

;; --- M-SPC b：Buffer（緩衝區管理） ---
;; 切換、刪除、複製緩衝區資訊等操作
(which-key-add-key-based-replacements
  "M-SPC b"   "buffer"
  "M-SPC b b" "switch"
  "M-SPC b k" "kill"
  "M-SPC b n" "name"
  "M-SPC b p" "path"
  "M-SPC b f" "full name"
  "M-SPC b r" "narrow"
  "M-SPC b w" "widen"
  )
(define-key my-leader-map (kbd "b b") 'persp-switch-to-buffer*)
(define-key my-leader-map (kbd "b k") 'persp-kill-buffer*)
(define-key my-leader-map (kbd "b n") 'my-buffer-name)
(define-key my-leader-map (kbd "b p") 'my-buffer-path)
(define-key my-leader-map (kbd "b f") 'my-buffer-full-name)
(define-key my-leader-map (kbd "b r") 'narrow-to-region)
(define-key my-leader-map (kbd "b w") 'widen)

;; --- M-SPC w：Window（視窗操作） ---
;; 分割、刪除、交換視窗位置等操作
(which-key-add-key-based-replacements
  "M-SPC w"     "window"
  "M-SPC w r"   "split right"
  "M-SPC w d"   "split down"
  "M-SPC w o"   "delete other windows"
  "M-SPC w w"   "delete"
  "M-SPC w s"   "swap"
  "M-SPC w s l" "swap left"
  "M-SPC w s r" "swap right"
  "M-SPC w s u" "swap up"
  "M-SPC w s d" "swap down"
  )
(define-key my-leader-map (kbd "w r") 'split-window-right-and-move-there-dammit)
(define-key my-leader-map (kbd "w d") 'split-window-down-and-move-there-dammit)
(define-key my-leader-map (kbd "w o") 'delete-other-windows)
(define-key my-leader-map (kbd "w w") 'delete-window)
(define-key my-leader-map (kbd "w s l") 'windmove-swap-states-left)
(define-key my-leader-map (kbd "w s r") 'windmove-swap-states-right)
(define-key my-leader-map (kbd "w s u") 'windmove-swap-states-up)
(define-key my-leader-map (kbd "w s d") 'windmove-swap-states-down)

;; --- M-SPC c：Consult（搜尋和導航） ---
;; 使用 consult 進行文字搜尋、函數導航、複製歷史等
(which-key-add-key-based-replacements
  "M-SPC c"   "consult"
  "M-SPC c l" "line"
  "M-SPC c g" "ripgrep"
  "M-SPC c i" "imenu"
  "M-SPC c m" "mark"
  "M-SPC c k" "yank from kill ring"
  )
(define-key my-leader-map (kbd "c l") 'consult-line)
(define-key my-leader-map (kbd "c g") 'consult-ripgrep)
(define-key my-leader-map (kbd "c i") 'consult-imenu)
(define-key my-leader-map (kbd "c m") 'consult-mark)
(define-key my-leader-map (kbd "c k") 'consult-yank-from-kill-ring)

;; ============================================================================
;; § Text Scale（文字大小調整）
;; ============================================================================
;; 功能：快速調整編輯區的文字大小
;; 工作方式：
;; - 使用 repeat-mode 實現按鍵重複
;; - 配合 which-key 顯示可用操作
;; - 配合 repeat-help 提供視覺反饋
;;
;; 快捷鍵（Leader key）：
;; - M-SPC t l：放大文字
;; - M-SPC t s：縮小文字
;; - M-SPC t r：重置文字大小
;; - 按住快捷鍵可連續調整

;; 啟用 repeat-mode（Emacs 28+ 內建）
;; 允許快捷鍵重複，提高調整效率
(repeat-mode 1)

;; 定義重置命令（避免 commandp 檢查失敗）
(defun my-text-scale-reset ()
  "重置文字大小到預設值"
  (interactive)
  (text-scale-adjust 0))

;; 定義 repeat map（重複按鍵的鍵盤映射）
(defvar my-text-scale-repeat-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "l") #'text-scale-increase)
    (define-key map (kbd "s") #'text-scale-decrease)
    (define-key map (kbd "r") #'my-text-scale-reset)
    map)
  "Repeat map for text scaling.")

;; 標記命令可用於 repeat mode
;; 當用戶按住快捷鍵時，會持續觸發
(put 'text-scale-increase 'repeat-map 'my-text-scale-repeat-map)
(put 'text-scale-decrease 'repeat-map 'my-text-scale-repeat-map)
(put 'my-text-scale-reset  'repeat-map 'my-text-scale-repeat-map)

;; 綁定到 leader map
(define-key my-leader-map (kbd "t l") #'text-scale-increase)
(define-key my-leader-map (kbd "t s") #'text-scale-decrease)
(define-key my-leader-map (kbd "t r") #'my-text-scale-reset)

;; 配置 which-key 提示
;; 顯示 M-SPC t 時會看到可用的文字大小調整選項
(which-key-add-key-based-replacements
  "M-SPC t"   "text scale"
  "M-SPC t l" "increase"
  "M-SPC t s" "decrease"
  "M-SPC t r" "reset")

;; 安裝 repeat-help 提供視覺反饋
;; 功能：在執行 repeat 操作時顯示幫助彈窗
;; 優勢：用戶能看到當前可用的按鍵和功能
;; 使用 hook 方式啟用，比 :config 更可靠
(use-package repeat-help
  :ensure t
  :after which-key
  :hook (repeat-mode . repeat-help-mode))

;; ============================================================================
;; § 自動保存設定
;; ============================================================================
;; 功能：Emacs 自動儲存檔案的備份副本
;; 優勢：
;; - 防止未保存的工作遺失
;; - 在 Emacs 崩潰時可以恢復
;; 位置：由 no-littering 自動移到隱藏的 .local/auto-save-list/ 目錄
(setq auto-save-default t)

;; ============================================================================
;; § 備份檔案設定
;; ============================================================================
;; 功能：為編輯的檔案保留備份副本，追蹤版本歷史
;; 優勢：
;; - 防止誤刪或意外修改
;; - 可以回滾到之前的版本
;;
;; 設定說明：
;; - version-control：啟用多版本備份（而不是覆蓋舊版本）
;; - kept-new-versions：保留 6 個最新版本
;; - kept-old-versions：保留 2 個舊版本
;; - delete-old-versions：超過上述數量時自動刪除
;; 位置：由 no-littering 自動移到隱藏的 .local/backup/ 目錄
(setq make-backup-files t
      version-control t           ; 啟用多版本備份
      kept-new-versions 6         ; 保留 6 個新版本
      kept-old-versions 2         ; 保留 2 個舊版本
      delete-old-versions t)      ; 自動刪除過多版本

;; ============================================================================
;; § 鎖檔機制：禁用
;; ============================================================================
;; 功能：Emacs 預設會為正在編輯的檔案建立 .#lockfile
;; 為什麼禁用：
;; - 在版本控制（git）環境中容易產生衝突
;; - 現代編輯工具可以更好地處理並發編輯
;; - 對於單使用者開發環境不必要
(setq create-lockfiles nil)

;; ============================================================================
;; § 解除高級命令的禁用
;; ============================================================================
;; 功能：Emacs 預設禁用某些高級但危險的命令，防止誤用
;; 這裡解除禁用是因為：
;; - narrow-to-page / narrow-to-defun：限制編輯範圍到特定區域，適合大型檔案
;; - upcase-region / downcase-region：批量改變文字大小寫
;; 這些對熟悉的使用者很有用，但需要謹慎使用
(put 'narrow-to-page    'disabled nil)
(put 'narrow-to-defun   'disabled nil)
(put 'upcase-region     'disabled nil)
(put 'downcase-region   'disabled nil)

;; ============================================================================
;; § windmove：視窗導航
;; ============================================================================
;; 功能：使用方向鍵 + Meta 快速切換視窗
;; 用法：
;; - M-↑ / M-↓ / M-← / M-→：移動到上/下/左/右的視窗
;; 優勢：比 C-x o（other-window）更直觀快速
(windmove-default-keybindings 'meta)
