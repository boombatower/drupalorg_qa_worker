; Drush Make (http://drupal.org/project/drush_make)
api = 2

; Drupal core

core = 7.x
projects[drupal][type] = core
projects[drupal][version] = 7.12

; Worker

projects[worker][type] = module
projects[worker][download][type] = git
projects[worker][download][url] = git://github.com/boombatower/worker.git
projects[worker][download][branch] = 7.x-1.x

projects[worker_drupal][type] = module
projects[worker_drupal][download][type] = git
projects[worker_drupal][download][url] = git://github.com/boombatower/worker_drupal.git
projects[worker_drupal][download][branch] = 7.x-1.x
