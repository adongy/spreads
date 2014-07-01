
; Definitions will be added above
 
SetCompressor lzma

; Modern UI installer stuff 
!include "MUI2.nsh"
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"

; UI pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"
; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${INSTALLER_NAME}"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
ShowInstDetails show

Section -SETTINGS
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd

Section "Python ${PY_VERSION}" sec_py
  File "python-${PY_VERSION}${ARCH_TAG}.msi"
  ExecWait 'msiexec /i "$INSTDIR\python-${PY_VERSION}${ARCH_TAG}.msi" /qb ALLUSERS=1'
  Delete $INSTDIR\python-${PY_VERSION}.msi
SectionEnd

;PYLAUNCHER_INSTALL
;------------------

Section "pywin32" sec_pywin32
  File "pywin32-${PY_VERSION}${ARCH_TAG}.exe"
  ExecWait "$INSTDIR\pywin32-${PY_VERSION}${ARCH_TAG}.exe"
  Delete $INSTDIR\pywin32-${PY_VERSION}${ARCH_TAG}.exe
SectionEnd

Section "pyexiv2" sec_pyexiv2
  File "pyexiv2-0.3.2${ARCH_TAG}.exe"
  ExecWait "pyexiv2-0.3.2${ARCH_TAG}.exe"
  Delete $INSTDIR\pyexiv2-0.3.2${ARCH_TAG}.exe
SectionEnd

Section "ImageMagick" sec_imagemagick
  File  "ImageMagick-6.5.6-8-Q8-windows-dll.exe"
  ExecWait '$INSTDIR\ImageMagick-6.5.6-8-Q8-windows-dll.exe /TASKS="modifypath,install_devel"'
  Delete $INSTDIR\ImageMagick-6.5.6-8-Q8-windows-dll.exe
SectionEnd

Section "ScanTailor" sec_scantailor
  File "scantailor-enhanced-20140214-32bit-install.exe"
  ExecWait "$INSTDIR\scantailor-enhanced-20140214-32bit-install.exe"
  Delete $INSTDIR\scantailor-enhanced-20140214-32bit-install.exe
SectionEnd

Section "Tesseract" sec_tesseract
  File "tesseract-ocr-setup-3.02.02.exe"
  ExecWait "$INSTDIR\tesseract-ocr-setup-3.02.02.exe"
  Delete $INSTDIR\tesseract-ocr-setup-3.02.02.exe
SectionEnd

Section "pdfbeads" sec_pdfbeads
  File "pdfbeads.exe"
  CopyFiles /SILENT $INSTDIR\pdfbeads.exe $PROGRAMFILES
  Delete $INSTDIR\pdfbeads.exe
SectionEnd

Section "jbig2" sec_jbig2
  File "jbig2.exe"
  CopyFiles /SILENT $INSTDIR\jbig2.exe $PROGRAMFILES
  Delete $INSTDIR\jbig2.exe
SectionEnd


Section "!${PRODUCT_NAME}" sec_app
  SectionIn RO
  File ${PRODUCT_ICON}
  SetOutPath "$INSTDIR\pkgs"
  File /r "pkgs\*.*"
  SetOutPath "$INSTDIR"
  ;INSTALL_FILES
  ;INSTALL_DIRECTORIES
  ;INSTALL_SHORTCUTS
  WriteUninstaller $INSTDIR\uninstall.exe
  ; Add ourselves to Add/remove programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "DisplayIcon" "$INSTDIR\${PRODUCT_ICON}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete $INSTDIR\uninstall.exe
  Delete "$INSTDIR\${PRODUCT_ICON}"
  RMDir /r "$INSTDIR\pkgs"
  ;UNINSTALL_FILES
  ;UNINSTALL_DIRECTORIES
  ;UNINSTALL_SHORTCUTS
  RMDir $INSTDIR
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
SectionEnd

; Functions

Function .onMouseOverSection
    ; Find which section the mouse is over, and set the corresponding description.
    FindWindow $R0 "#32770" "" $HWNDPARENT
    GetDlgItem $R0 $R0 1043 ; description item (must be added to the UI)

    StrCmp $0 ${sec_py} 0 +2
      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The Python interpreter. \
            This is required for ${PRODUCT_NAME} to run."
    ;
    ;PYLAUNCHER_HELP
    ;------------------

    StrCmp $0 ${sec_pywin32} 0 +2
      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The pywin32 library. \
            This is required for ${PRODUCT_NAME} to run."

    StrCmp $0 ${sec_app} "" +2
      SendMessage $R0 ${WM_SETTEXT} 0 "STR:${PRODUCT_NAME}"
FunctionEnd
