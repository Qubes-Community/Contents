Using multiple languages in dom0
================================

Installing additional languages
-------------------------------

Switching languages is pretty easy in your domUs. However, in dom0, there's only
English available after installation if no additional languages have been installed.
To install more languages in dom0, use the following command:

~~~
sudo qubes-dom0-update glibc-langpack-LANGUAGE
~~~

Note that `LANGUAGE` should be a valid language code, e.g. `en` for English, `de` for
German, `it` for Italian and so on.

You can check which languages are available on your system using:

~~~
localectl list-locales
~~~

Setting a language globally
---------------------------

If you want to switch your whole dom0 from English to some other language,
edit the file `/etc/locale.conf` to include your language code for the `LANG=` value.
For example, to change your dom0 to Italian, the file `/etc/locale.conf` should contain:

~~~
LANG="it_IT.UTF-8"
~~~

Important: Using some language other than English is not officially supported, i.e. you
might still get a lot of English content which has not been translated to your desired language.

Setting only some formats
-------------------------

If you just want to change some format specifiers, you can add the `LC_*` identifier
in the same file, below the `LANG=` code. Avoid the `LC_ALL` identifier, because it overwrites
all previous settings! For example, to use German time formats but still use the English
language as default for anything else, you would write the following in `/etc/locale.conf`:

~~~
LANG="en_US.UTF-8"
LC_TIME="de_DE.UTF-8"
~~~

Those codes must be supported by your dom0 (check with `localectl list-locales`).

After you finished editing, check your new setup with `localectl status`. You might need
to logout and login back again to enable your changes in the environment (e.g. in the window
manager or its applets).

You might also want to inspect the changes introduced by adding/editing one `LC_*` rule
in the config file. Use `locale -k $rule` for this purpose, e.g. `locale -k LC_TIME` to
show the formats exported by the setting of the `LC_TIME`.

If you see "broken characters" like `�` somewhere, check the encoding of the affected
application. The default terminal emulator in dom0 does not use Unicode as default
encoding and therefore has some problems when it's not adjusted accordingly. 
