module.exports = (grunt) ->
  # Do grunt-related things in here
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      compile: {
        files: {
          'assets/javascript/<%= pkg.name %>-<%= pkg.version %>.js': 'assets/javascript/<%= pkg.name %>.coffee'
        }
      }
    },

    sass: {
      options: {
        bundleExec: true,
        style: 'compressed'
      },
      build: {
        files: {
          'assets/stylesheets/style.css': 'assets/stylesheets/style.scss'
        }
      }
    },

    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= pkg.version %> */\n',
        report: 'min'
      },
      build: {
        files: {
          'assets/javascript/<%= pkg.name %>-<%= pkg.version %>.min.js': ['assets/javascript/<%= pkg.name %>-<%= pkg.version %>.js']
        }
      }
    },

    watch: {
      script: {
        files: ['assets/javascript/**/*.coffee'],
        tasks: ['coffee', 'uglify']
      },
      stylesheets: {
        files: ['assets/stylesheets/**/*.scss'],
        tasks: ['sass']
      }
    }
  })

  # Load plugins for 'coffee'-, 'compass'- and 'uglify'-tasks.
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  # Default task(s).
  grunt.registerTask 'default', ['watch']
