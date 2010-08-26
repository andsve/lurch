# lurch - Modular Lua IRC bot

This is an experiment in Lua to create a IRC bot with modular support via git repos.

**Requires Lua, LuaSockets and Git**

## Usage

Run from inside the git repo: `lua bot.lua <serverhost> <serverport>`

Once the bot has connected it will automatically join the #lurchbot channel.

## Configuration

Configuration is done via an external script file called `settings.lua`.
You can either create this on your own using the following syntax, or let the bot create it from the running configuration via the `:saveconf` command. Likewise can you reload the config with the `:loadconf` command.

    module("settings")
    modules = {define = "git://gist.github.com/546307.git"  -- a table of modules that can be loaded
              }                                             -- formated like this: {modulename = git-repo-url}
    altnicks = {"lurch",                                    -- alternative nicknames
               "lurch_"
               }
    triggerprefix = ":"                                     -- prefix to use in the begining of triggers
    channels = {"lurchbot"                                  -- channels to autojoin
               }
    nickname = "lb"                                         -- default nickname of bot
    

## Standard commands and triggers

### Core commands (can only be executed by trusted users)

* `:echo <text>` -- Makes the bot say `text`.

* `:quit` -- Disconnects the bot.

* `:reload` -- Reload bot, ie. pull latest git repo and reload core.lua.

* `:saveconf` -- Saves current configuration to settings.lua.

* `:loadconf` -- Loads previously saved configuration from settings.lua.

* `:clearqueue` -- Clear message queue.

* `:loadmod <modulename> [moduleurl]` -- Load a module; Clone git repo from `moduleurl` into `modules/modulename/`. If `moduleurl` is omitted, it will will use the previously stored git repo url.

* `:unloadmod <modulename>` -- Unloads the module.

* `:join <channel>` -- Makes the bot join the `channel`.

* `:nick <newnick>` -- Makes the bot try to change nickname to `newnick`.

* `:exec <code>` -- Executes the Lua `code`.

### Public commands (can be executed by any user)

* `:help` -- Shows all available public commands.

* `:git` -- Shows information of the bots git repo.

It's easy to add new triggers, just have a look inside `triggers.lua` and it should be self explanatory.

## Module support

Lurch can load modules via git. The best way to understand how they work is to look at one of the samples below:

* define -- Adds a :define trigger via the modules system. The trigger will send a search request to google and parse out the first best definition of the word supplied.  
  Url: `http://gist.github.com/546307`  
  To load it: `:loadmod define git://gist.github.com/546307.git`
  
* title -- Tracks the last url to be said, and looks up the the page title on request (`:title`).
    Url: `http://gist.github.com/551547`  
    To load it: `:loadmod title git://gist.github.com/551547.git`
