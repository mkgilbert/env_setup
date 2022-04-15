# Follow these instructions when setting up a new Mac

1. install Karabiner
  1. go [here](https://github.com/pqrs-org/Karabiner-Elements/releases/latest/) and click Download"
  2. run the dmg file and follow gui installation
  3. Open karabiner-elements and follow prompts to allow it in security prefs
  4. Go [here](karabiner://karabiner/assets/complex_modifications/import?url=https://msol.io/files/karabiner/ctrlw.json), open that with Karabiner
    - alternatively, add the hyper.json file to the `complex_modifications` setting of `~/.config/karabiner/karabiner.json`
1. Run `setup.sh`
2. Install the keepassxc-browser firefox add-on
  - https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/
  - Open keepassxc on Mac
    - Preferences > Browser Integration
      - check box "Enable browser integration"
      - check chrome and firefox browser boxes
      - If you get an error about the script being able to be written:
        - `sudo chown gilbert32 ~/Library/Application\ Support/Mozilla/NativeMessagingHosts/`
        - More troubleshooting info [here](https://github.com/keepassxreboot/keepassxc-browser/wiki/Troubleshooting-guide)
  - On firefox extension, click "reload"
    - This should open a dialog box (most likely hidden somewhere on your primary screen's
      workspace 1). Enter a name there and you're done

