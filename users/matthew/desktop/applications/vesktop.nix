{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [vesktop];

  xdg.configFile = let
    json = pkgs.formats.json {};
  in {
    "vesktop/settings.json".source = json.generate "settings.json" {
      minimizeToTray = true;
      discordBranch = "stable";
      firstLaunch = false;
      staticTitle = true;
      appBadge = false;
      maximized = true;
      minimized = false;
      hardwareAcceleration = true;
      spellCheckLanguages = ["en-GB" "en-CA" "en"];
      splashColor = "rgb(205, 214, 244)";
      splashBackground = "rgb(30, 30, 46)";
    };

    "vesktop/settings/settings.json".source = json.generate "vesktop-settings.json" {
      notifyAboutUpdates = true;
      autoUpdate = false;
      autoUpdateNotification = false;
      useQuickCss = true;
      themeLinks = [
        "@light https://catppuccin.github.io/discord/dist/catppuccin-latte-${config.catppuccin.accent}.theme.css"
        "@dark https://catppuccin.github.io/discord/dist/catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}.theme.css"
      ];
      enabledThemes = [];
      enableReactDevtools = false;
      frameless = false;
      transparent = true;
      winCtrlQ = false;
      disableMinSize = false;
      winNativeTitleBar = false;
      notifications = {
        timeout = 5000;
        position = "bottom-right";
        useNative = "not-focused";
        logLimit = 50;
      };

      cloud = {
        authenticated = false;
        url = "https://api.vencord.dev/";
        settingsSync = false;
        settingsSyncVersion = 1733509761749;
      };

      plugins = {
        BadgeAPI.enabled = true;
        ChatInputButtonAPI.enabled = true;
        CommandsAPI.enabled = true;
        ContextMenuAPI.enabled = true;
        MemberListDecoratorsAPI.enabled = false;
        MessageAccessoriesAPI.enabled = true;
        MessageDecorationsAPI.enabled = false;
        MessageEventsAPI.enabled = true;
        MessagePopoverAPI.enabled = false;
        NoticesAPI.enabled = true;
        ServerListAPI.enabled = false;
        NoTrack = {
          enabled = true;
          disableAnalytics = true;
        };
        Settings = {
          enabled = true;
          settingsLocation = "aboveActivity";
        };
        SupportHelper.enabled = true;
        AlwaysAnimate.enabled = false;
        AlwaysTrust.enabled = false;
        AnonymiseFileNames = {
          enabled = false;
          anonymiseByDefault = true;
          method = 0;
          randomisedLength = 7;
          consistent = "image";
        };
        "WebRichPresence (arRPC)".enabled = false;
        BANger.enabled = false;
        BetterFolders.enabled = false;
        BetterGifAltText.enabled = false;
        BetterGifPicker.enabled = false;
        BetterNotesBox.enabled = false;
        BetterRoleDot.enabled = false;
        BetterUploadButton.enabled = false;
        BiggerStreamPreview.enabled = false;
        BlurNSFW.enabled = false;
        CallTimer = {
          enabled = true;
          format = "human";
        };
        ClearURLs.enabled = false;
        ClientTheme.enabled = false;
        ColorSighted.enabled = false;
        ConsoleShortcuts.enabled = false;
        CopyUserURLs.enabled = false;
        CrashHandler.enabled = true;
        CustomRPC.enabled = false;
        Dearrow.enabled = false;
        Decor.enabled = false;
        DisableCallIdle.enabled = false;
        EmoteCloner.enabled = false;
        Experiments = {
          enabled = false;
          enableIsStaff = false;
          toolbarDevMenu = false;
        };
        F8Break.enabled = false;
        FakeNitro.enabled = false;
        FakeProfileThemes.enabled = false;
        FavoriteEmojiFirst.enabled = false;
        FavoriteGifSearch.enabled = false;
        FixCodeblockGap.enabled = false;
        FixSpotifyEmbeds.enabled = false;
        FixYoutubeEmbeds.enabled = false;
        ForceOwnerCrown.enabled = true;
        FriendInvites.enabled = false;
        GameActivityToggle.enabled = false;
        GifPaste.enabled = true;
        GreetStickerPicker.enabled = false;
        HideAttachments.enabled = false;
        iLoveSpam.enabled = false;
        IgnoreActivities.enabled = false;
        ImageZoom.enabled = false;
        InvisibleChat.enabled = false;
        KeepCurrentChannel.enabled = false;
        LastFMRichPresence.enabled = false;
        LoadingQuotes.enabled = false;
        MemberCount = {
          enabled = true;
          toolTip = true;
          memberList = true;
        };
        MessageClickActions.enabled = false;
        MessageLinkEmbeds.enabled = false;
        MessageLogger.enabled = false;
        MessageTags.enabled = false;
        MoreCommands.enabled = false;
        MoreKaomoji.enabled = false;
        MoreUserTags.enabled = false;
        Moyai = {
          enabled = false;
          volume = {
          };
          quality = "Normal";
          triggerWhenUnfocused = true;
          ignoreBots = true;
          ignoreBlocked = true;
        };
        MutualGroupDMs.enabled = false;
        NewGuildSettings.enabled = false;
        NoBlockedMessages.enabled = false;
        NoDevtoolsWarning.enabled = false;
        NoF1.enabled = true;
        NoMosaic.enabled = false;
        NoPendingCount = {
          enabled = true;
          hideFriendRequestsCount = true;
          hideMessageRequestsCount = true;
          hidePremiumOffersCount = true;
        };
        NoProfileThemes.enabled = false;
        NoReplyMention = {
          enabled = true;
          userList = "";
          shouldPingListed = true;
          inverseShiftReply = false;
        };
        NoScreensharePreview.enabled = false;
        NoTypingAnimation.enabled = true;
        NoUnblockToJump.enabled = false;
        NormalizeMessageLinks.enabled = true;
        NotificationVolume.enabled = false;
        NSFWGateBypass.enabled = false;
        OnePingPerDM = {
          enabled = true;
          channelToAffect = "both_dms";
          allowMentions = false;
          allowEveryone = false;
        };
        oneko.enabled = false;
        OpenInApp.enabled = false;
        PermissionFreeWill.enabled = false;
        PermissionsViewer.enabled = false;
        petpet.enabled = false;
        PictureInPicture.enabled = false;
        PinDMs.enabled = false;
        PlainFolderIcon.enabled = false;
        PlatformIndicators.enabled = false;
        PreviewMessage.enabled = false;
        QuickMention.enabled = false;
        QuickReply.enabled = false;
        ReactErrorDecoder.enabled = false;
        ReadAllNotificationsButton.enabled = false;
        RelationshipNotifier.enabled = false;
        RevealAllSpoilers.enabled = false;
        ReverseImageSearch.enabled = false;
        ReviewDB.enabled = false;
        RoleColorEverywhere.enabled = false;
        SecretRingToneEnabler.enabled = false;
        SendTimestamps = {
          enabled = false;
          replaceMessageContents = true;
        };
        ServerListIndicators.enabled = false;
        ShikiCodeblocks = {
          enabled = false;
          theme = "https://raw.githubusercontent.com/shikijs/shiki/0b28ad8ccfbf2615f2d9d38ea8255416b8ac3043/packages/shiki/themes/dark-plus.json";
          tryHljs = "SECONDARY";
          useDevIcon = "GREYSCALE";
          bgOpacity = 100;
        };
        ShowAllMessageButtons.enabled = false;
        ShowConnections.enabled = false;
        ShowHiddenChannels.enabled = false;
        ShowMeYourName.enabled = false;
        SilentMessageToggle.enabled = false;
        SilentTyping = {
          enabled = true;
          showIcon = false;
          isEnabled = true;
          contextMenu = true;
        };
        SortFriendRequests.enabled = false;
        SpotifyControls.enabled = false;
        SpotifyCrack.enabled = false;
        SpotifyShareCommands.enabled = false;
        StartupTimings.enabled = false;
        SuperReactionTweaks.enabled = false;
        TextReplace.enabled = false;
        ThemeAttributes.enabled = false;
        TimeBarAllActivities.enabled = false;
        Translate.enabled = false;
        TypingIndicator.enabled = false;
        TypingTweaks.enabled = false;
        Unindent.enabled = true;
        UnsuppressEmbeds.enabled = false;
        UrbanDictionary.enabled = false;
        UserVoiceShow.enabled = false;
        USRBG.enabled = false;
        ValidUser.enabled = false;
        VoiceChatDoubleClick.enabled = false;
        VcNarrator.enabled = false;
        VencordToolbox.enabled = false;
        ViewIcons.enabled = false;
        ViewRaw.enabled = false;
        VoiceMessages.enabled = false;
        WebContextMenus = {
          enabled = true;
          addBack = true;
        };
        WebKeybinds.enabled = true;
        WhoReacted.enabled = false;
        Wikisearch.enabled = false;
        XSOverlay.enabled = false;
        ShowHiddenThings.enabled = false;
        PartyMode = {
          enabled = false;
          superIntensePartyMode = 0;
        };
        ServerInfo.enabled = false;
        MessageUpdaterAPI.enabled = false;
        UserSettingsAPI.enabled = true;
        AppleMusicRichPresence.enabled = false;
        AutomodContext.enabled = false;
        BetterRoleContext.enabled = false;
        BetterSessions.enabled = false;
        BetterSettings.enabled = false;
        ConsoleJanitor.enabled = false;
        CopyEmojiMarkdown.enabled = false;
        CtrlEnterSend.enabled = false;
        CustomIdle = {
          enabled = true;
          idleTimeout = 0;
          remainInIdle = true;
        };
        DontRoundMyTimestamps.enabled = false;
        FriendsSince.enabled = false;
        ImageLink.enabled = false;
        ImplicitRelationships.enabled = false;
        MaskedLinkPaste.enabled = false;
        MentionAvatars.enabled = false;
        MessageLatency.enabled = false;
        NoDefaultHangStatus.enabled = false;
        NoOnboardingDelay.enabled = false;
        NoServerEmojis.enabled = false;
        OverrideForumDefaults.enabled = false;
        PauseInvitesForever.enabled = false;
        ReplaceGoogleSearch.enabled = false;
        ReplyTimestamp.enabled = false;
        Summaries.enabled = false;
        ShowTimeoutDuration.enabled = false;
        StreamerModeOnStream.enabled = false;
        UnlockedAvatarZoom.enabled = false;
        ValidReply.enabled = false;
        VoiceDownload.enabled = false;
        WebScreenShareFixes.enabled = true;
        AlwaysExpandRoles.enabled = false;
        YoutubeAdblock.enabled = false;
        FullSearchContext.enabled = false;
        AccountPanelServerProfile.enabled = false;
        CopyFileContents.enabled = true;
        NoMaskedUrlPaste.enabled = true;
        StickerPaste.enabled = false;
        VolumeBooster.enabled = false;
        UserMessagesPronouns.enabled = false;
        DynamicImageModalAPI.enabled = false;
        FixImagesQuality.enabled = false;
      };
    };
  };
}
