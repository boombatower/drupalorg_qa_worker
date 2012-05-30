# Worker for qa.drupal.org

This project contains the make files for building workers used by qa.drupal.org. The project is intended to be used with [Drush make](http://drupal.org/project/drush).

In order to build out to codebase for a qa.drupal.org worker perform the following.

    $ drush make --yes https://raw.github.com/boombatower/drupalorg_qa_worker/7.x-1.x/[WORKER_TYPE].make

All the available worker types are listed below.

    $ drush make --yes https://raw.github.com/boombatower/drupalorg_qa_worker/7.x-1.x/worker.make
    $ drush make --yes https://raw.github.com/boombatower/drupalorg_qa_worker/7.x-1.x/worker_drupal.make

Otherwise, you can obtain the drupal.make file via another method. If you want a *working-copy* (aka one that has git checkouts of the applicable projects) you can add `--working-copy` as shown below. In addition, `--no-gitinfofile` is handy since it does not alter the .info files which will make it more difficult to commit changes.

    $ drush make --working-copy --no-gitinfofile --yes https://raw.github.com/boombatower/drupalorg_qa_worker/7.x-1.x/worker.make

Next the worker can be installed by executing the following (assuming access to SQLite) or setting up a database and changing the command. Please note that the Drupal installation for the worker does not need to be accessible from the web.

    $ drush si minimal --yes --site-name='Worker' --account-name=worker --account-pass=worker --db-url=sqlite:sites/default/files/.ht.sqlite
    $ drush en --yes worker [WORKER_TYPE] # enable WORKER_TYPE if applicable

If the worker type requires a separate database to be configured add something like the following to `settings.php`.

```php
<?php
// Database that Drupal will be installed in. This database is dropped and
// created every job run using the stub database as a connection.
$databases['drupal_mysql'] = array(
  'default' => array(
    'database' => '',
    'username' => '',
    'password' => '',
    'host' => 'localhost',
    'port' => '',
    'driver' => 'mysql',
    'prefix' => '',
  ),
);
// Stub database used to make a connection using the appropriate driver. This
// database must be created manually and will not be created or destroyed.
$databases['drupal_mysql_stub'] = $databases['drupal_mysql'];
$databases['drupal_mysql_stub']['default']['database'] .= '_stub';
```

All workers will need the following settings added to `settings.php`. The category is `conduit` for `worker.make` and `worker_[CATEGORY].make` for any other. The concurrency is the maximum number of process to create at any given time, which should be based off the hardware being used by the worker.

```php
<?php
$conf['worker_url'] = 'http://example.com/conduit';
$conf['worker_login'] = array(
  'username' => 'worker',
  'password' => 'worker',
);
$conf['worker_category'] = 'conduit';
$conf['worker_concurrency'] = 4;
```

The worker needs a consistent way to refer to the "embedded" Drupal installation that runs SimpleTest. To accomplish this, we decided to:

  - set the JOB_URL constant to "worker.loc" in job.inc
  - add an entry for "worker.loc" in /etc/hosts
  - create a virtual host entry for "worker.loc" as follows

In this case `/srv/www/htdocs/` points to the Drupal root of the worker so `/srv/www/htdocs/sites/default/files/job` points to the directory in which the embedded Drupal will be located.

    <VirtualHost *>
      ServerName worker.loc
      ServerAlias *.worker.loc
      ServerAdmin root@site.loc

      ErrorLog /dev/null
      CustomLog /dev/null combined

      DocumentRoot /srv/www/htdocs/sites/default/files/job
      <Directory /srv/www/htdocs/sites/default/files/job>
        AllowOverride FileInfo AuthConfig Limit Indexes Options=All,MultiViews
        Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
        Order allow,deny
        Allow from all
      </Directory>
    </VirtualHost>
