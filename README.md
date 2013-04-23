lunchy.sh
=========

`lunchy.sh` is a simple way to interact with OS X's `launchctl`.
`launchctl` is straight-forward program, but its interface requires you to pass
it full path information for the agents you're launching. Blech.

To save you from having to remember or track down all these paths, `lunchy.sh`
turns this:

    launchctl load /usr/local/opt/mongodb/homebrew.mxcl.mongodb.plist

...into this:

    lunchy start mongo


`lunchy.sh` is a simple way to interact with the OS X `launchctl` application.
It's based on the idea behind [lunchy Ruby gem](https://github.com/mperham/lunchy),
but provides a couple of improvements:

  * `lunchy.sh` doesn't put files into `~/Library/LaunchAgents`. Files in this
directory are automatically started when the system boots, defeating the purpose
of having them managed.
  * `lunchy.sh` doesn't copy files into another diretory, so if those
LaunchAgents are updated (maybe through [`homebrew`](http://mxcl.github.io/homebrew/)),
those updates will be reflected the next time the agent is (re)started.


`lunchy.sh`'s goal is to maintain simplicity, and to that end has a only a few very
simple commands:

    * ls [pattern]        List all launch agents, or only ones matching the given pattern.
    * start {pattern}     Start the launch agent matching the given pattern.
    * stop {pattern}      Stop the launch agent matching the given pattern.
    * restart {pattern}   Restart the launch agent matching the given pattern.
    * status [pattern]    Display the status of all launch agents, or only the ones matching the pattern.
    * install {file}      Make lunchy aware of the given launch agent.
    * uninstall {file}    Make lunch unaware of the given launch agent.
    * show {pattern}      See the launch agent with the specified pattern
    * edit {pattern}      Edit the launch agent with the specified pattern


License
-------

`lunchy.sh` is MIT licensed. Please see the included `LICENSE` file for more information.

Author
------

Bill Israel - [@epochblue](https://twitter.com/epochblue) - [http://billisrael.info/](http://billisrael.info/]
