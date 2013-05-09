module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    clean:
      build: ['build']

    coffee:
      compile:
        files:
          'assets/javascript/<%= pkg.name %>-<%= pkg.version %>.js': 'assets/javascript/<%= pkg.name %>.coffee'

    copy:
      build:
        files:
          'build/': ['index.html', 'assets/fonts/**', 'assets/javascript/**/*.min.js', 'assets/stylesheets/*.css']

    jshint:
      options:
        browser: true
        curly: true
        eqeqeq: true
        undef: true
        unused: true
        strict: true
        trailing: true
      check:
        files:
          # do not check minified files
          src: ['assets/javascript/**/*.js', '!assets/javascript/**/*.min.js']

    sass:
      options:
        bundleExec: true
        style: 'compressed'
      compile:
        files:
          'assets/stylesheets/style.css': 'assets/stylesheets/style.scss'

    uglify:
      options:
        banner: '/*! <%= pkg.name %> <%= pkg.version %> */\n'
        report: 'min'
      build:
        files:
          'assets/javascript/<%= pkg.name %>-<%= pkg.version %>.min.js': 'assets/javascript/<%= pkg.name %>-<%= pkg.version %>.js'

    watch:
      script:
        files: 'assets/javascript/**/*.coffee'
        tasks: ['coffee', 'jshint', 'uglify']
      stylesheets:
        files: 'assets/stylesheets/**/*.scss'
        tasks: 'sass'

  # Load plugins
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['sass', 'coffee', 'jshint', 'uglify', 'watch']
  grunt.registerTask 'build', ['sass', 'coffee', 'jshint', 'uglify', 'clean:build', 'copy:build']
