Wiener Linien Generator
=======================

The Wiener Linien real time departure server provides real time departure data for Vienna. Getting the data isn't as easy as in different regions though as the server requires you to ask for platform IDs instead of the usual station IDs. To look up a station you need to figure the platform (RBL) IDs first. This is done using the 3 seperate CSV files which contain the line, platform and station information. Wouldn't it be nice if you could have a JSON array of stations with their platforms as a subarray instead? This tool helps you generate this.

If you're not interested in the app you can download a ready to use JSON file [here.](https://gist.github.com/hactar/6793144) note though that this file may not be uptodate as it was generated in September 2013. If the files at [Wiener Linien - Echtzeitdaten](https://open.wien.at/site/datensatz/?id=add66f20-d033-4eee-b9a0-47019828e698) have been updated, you'll need to regenerate this file.

The resulting structure is this:
![Screenshot](http://subzero.eu/wann/wp-content/uploads/2013/10/wlgenerator.png)

This app is a tool for developers. It generates a JSON file for usage in your apps. It creates a JSON array of station dictionaries, with the platforms and line information merged in.

Takes the 3 Wiener Linien CSV files for the RBL server, removes some of the unrequired items, fixes some discrepancies and merges them into a JSON file for use in your app. The JSON file is placed on your desktop.

This JSON file is used in the iOS App [Wann](https://subzero.eu/wann)

The app is provided under the MIT license.

Instructions
============

* Download the 3 CSV files from [Wiener Linien - Echtzeitdaten](https://open.wien.at/site/datensatz/?id=add66f20-d033-4eee-b9a0-47019828e698)
* Launch the app and feed in the 3 CSV in the order the app asks for them
* The generated JSON file is placed on your desktop (wl.json).

Requirements
============

* Mac OS X

Todo
====

The tool is fully functional, but coded for personal use, as such it only contains minimal error checking and you'll need to adapt it if you need a different resulting JSON structure.