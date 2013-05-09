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

    compass: {
      dist: {
        options: {
          sassDir: 'assets/stylesheets',
          cssDir: 'assets/stylesheets',
          outputStyle: 'compressed'
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
    }
  })

  # Load plugins for 'coffee'-, 'compass'- and 'uglify'-tasks.
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-compass'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  # Default task(s).
  grunt.registerTask 'default', ['compass', 'coffee', 'uglify']
