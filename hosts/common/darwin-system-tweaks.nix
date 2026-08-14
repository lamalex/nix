{ username, pkgs, ... }:
{
  users.users.${username}.shell = pkgs.fish;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  programs.fish.enable = true;

  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowScrollBars = "Always";
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;
    NSGlobalDomain.NSUseAnimatedFocusRing = false;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    # Hold a letter key -> accent menu (mutually exclusive with hold-to-repeat;
    # setting false would enable key repeat instead)
    NSGlobalDomain.ApplePressAndHoldEnabled = true;
    # Repeat speed for keys without accents (arrows, delete, ...)
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    LaunchServices.LSQuarantine = false;
    loginwindow.GuestEnabled = false;
    finder.FXPreferredViewStyle = "clmv";
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      FXDefaultSearchScope = "SCcf";
      DisableAllAnimations = true;
      NewWindowTarget = "PfDe";
      NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowStatusBar = true;
      ShowPathbar = true;
      WarnOnEmptyTrash = false;
    };

    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };

    "com.apple.dock" = {
      autohide = true;
      launchanim = false;
      static-only = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";
      tilesize = 55;
      minimize-to-application = true;
      mineffect = "scale";
      enable-window-tool = false;
    };

    "com.apple.ActivityMonitor" = {
      OpenMainWindow = true;
      IconType = 5;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };

    "com.apple.AdLib".allowApplePersonalizedAdvertising = false;

    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      ScheduleFrequency = 1;
      AutomaticDownload = 1;
      CriticalUpdateInstall = 1;
    };

    # Disable Spotlight keyboard shortcuts:
    #   64 = "Show Spotlight search" (Cmd+Space)
    #   65 = "Show Finder search window" (Alt+Cmd+Space)
    "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
      "64".enabled = false;
      "65".enabled = false;
    };

    # Bind Raycast launcher to Cmd+Space (49 = Space key code)
    "com.raycast.macos".raycastGlobalHotkey = "Command-49";

    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    "com.apple.ImageCapture".disableHotPlug = true;
    "com.apple.commerce".AutoUpdate = true;

    "com.googlecode.iterm2".PromptOnQuit = false;

    # Hold-to-repeat in the terminal (overrides the global accent-menu setting)
    "com.mitchellh.ghostty".ApplePressAndHoldEnabled = false;

    "com.google.Chrome" = {
      AppleEnableSwipeNavigateWithScrolls = true;
      DisablePrintPreview = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
  };
}
