
###  GIT workflow
1. Create a branch for your feature:

   ```
    git checkout master
    git pull
    git checkout -b myfeature
  ```
2. Make (and commit) changes in _myfeature_ branch.
3. Run code analyzer and fix issues if any:

  ```
  bundle exec pronto run -c origin/master
  ```
4. When the feature is ready, rebase it against the freshest version of _master_ branch:

   ```
    git checkout master
    git pull
    git rebase master myfeature
   ```
  Note: This is the last chance to squash/cleanup/rearrange _myfeature_ branch commit history. Do it by using -i option:
    `git rebase -i master`,
    edit and save the file.
    
  * https://help.github.com/articles/about-git-rebase/
  * https://help.github.com/articles/using-git-rebase/
5. Push _myfeature_ branch to GitHub (
  `git push origin myfeature`) .
Create a pull request (via GutHub UI). Invite someone from the team to review the changes. Discuss.
6. If necessary, make more changes to _myfeature_ branch. Push it to GitHub again (like on step 4).
  Note: only use 'git rebase' on this stage if you are the only person working on _myfeature_ branch.
7. [optional] After the pull request has been fully discussed and completed, and right before the final merge to master branch, you can 'git rebase' against freshest master again in order to cleanup commit history and simplify further merge process.
8. Merge pull request to master throught Github UI
Note: you can also do it manually via 
  ```
git checkout master
git merge myfeature
git push origin master
```
8. Every commit pushed to master is deployed automatically to Heroku
9. Delete _myfeature_ branch locally (`git branch -d myfeature`) and on Github as well ( through 'Delete branch' button on closed PR )

### Heroku deployment
Running on Heroku at: http://kisoils.heroku.com/.

### Running locally 
```
bundle install
bower install
rails s
```

If unable to bundle-install 'rugged' gem, try this:
```
sudo apt-get install cmake
```


####  Environment Variables
Development reads environment variables from .env file, using the 'dotenv-rails' gem


### Running tests
! Install PhantomJS on your OS as described here: https://github.com/teampoltergeist/poltergeist

To run all tests:
``` 
rake test
```
Single test: `ruby -Itest path/to/your/test.rb`


### Background jobs
Dependencies:
* Redis
* Sidekiq

Sidekiq background job interface can be found at:
http://kisoils.herokuapp.com/sidekiq


### Barcode Images
Barcode images are generated in the /tmp directory and uploaded to Cloudinary (Heroku add-on).
We don't need to keep these files around so we should write a script to clear them out before long.

###  Other
To add "Schema Info" comment to all models, tests, and factories run `annotate`
