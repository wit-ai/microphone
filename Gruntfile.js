// Generated on 2014-01-21 using generator-webapp 0.4.4
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to recursively match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {
  // show elapsed time at the end
  require('time-grunt')(grunt);
  // load all grunt tasks
  require('load-grunt-tasks')(grunt);

  grunt.initConfig({
    // configurable paths
    yeoman: {
      app: 'app',
      dist: 'dist',
      tmp: '.tmp'
    },
    watch: {
      compass: {
        files: ['<%= yeoman.app %>/*.{scss,sass}'],
        tasks: ['compass']
      },
      copy: {
        files: ['<%= yeoman.app %>/**/*.{js,css,html,svg,eot,ttf,woff}'],
        tasks: ['copy:js_css_fonts_to_tmp']
      },
      coffee: {
        files: ['<%= yeoman.app %>/**/*.coffee'],
        tasks: ['coffee']
      },
      livereload: {
        options: {
          livereload: '<%= connect.options.livereload %>'
        },
        files: [
          '<%= yeoman.app %>/**/*.html',
          '.tmp/**/*.{js,css,html,svg}',
          '<%= yeoman.app %>/**/images/{,*/}*.{gif,jpeg,jpg,png,svg,webp}'
        ]
      }
    },
    connect: {
      options: {
        port: 9000,
        livereload: 35728,
        // change this to '0.0.0.0' to access the server from outside
        hostname: 'localhost'
      },
      livereload: {
        options: {
          open: true,
          base: [
            '.tmp',
            '<%= yeoman.app %>'
          ]
        }
      },
      test: {
        options: {
          base: [
            '.tmp',
            'test',
            '<%= yeoman.app %>'
          ]
        }
      },
      dist: {
        options: {
          open: true,
          base: '<%= yeoman.dist %>',
          livereload: false
        }
      }
    },
    clean: {
      default: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= yeoman.dist %>/*',
            '!<%= yeoman.dist %>/.git*'
          ]
        }]
      }
    },
    coffee: {
      default: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>',
          src: '**/*.coffee',
          dest: '.tmp',
          ext: '.js'
        }]
      }
    },
    compass: {
      options: {
        sassDir: '<%= yeoman.app %>',
        cssDir: '.tmp',
        generatedImagesDir: '.tmp/images/generated',
        imagesDir: '<%= yeoman.app %>/images',
        javascriptsDir: '<%= yeoman.app %>/scripts',
        fontsDir: '<%= yeoman.app %>/styles/fonts',
        importPath: '<%= yeoman.app %>/bower_components',
        httpImagesPath: '/images',
        httpGeneratedImagesPath: '/images/generated',
        httpFontsPath: '/styles/fonts',
        relativeAssets: false,
        assetCacheBuster: false
      },
      default: {
        options: {
        }
      }
    },
    // not used since Uglify task does concat,
    // but still available if needed
    /*concat: {
      dist: {}
      },*/
    // not enabled since usemin task does concat and uglify
    // check index.html to edit your build targets
    // enable this task if you prefer defining your build targets here
    /*uglify: {
        dist: {}
      },*/
    rev: {
      dist: {
        files: {
          src: [
            '<%= yeoman.dist %>/{,*/}*.js',
            '<%= yeoman.dist %>/{,*/}*.css',
            '<%= yeoman.dist %>/{,*/}/images/*.{gif,jpeg,jpg,png,webp}',
            '<%= yeoman.dist %>/fonts/{,*/}*.*'
          ]
        }
      }
    },
    useminPrepare: {
      options: {
        dest: '<%= yeoman.dist %>'
      },
      html: '<%= yeoman.app %>/**/index.html'
    },
    usemin: {
      options: {
        assetsDirs: ['<%= yeoman.dist %>']
      },
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/{,*/}*.css']
    },
    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}images/*.{gif,jpeg,jpg,png}',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },
    svgmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.svg',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },
    cssmin: {
      // This task is pre-configured if you do not wish to use Usemin
      // blocks for your CSS. By default, the Usemin block from your
      // `index.html` will take care of minification, e.g.
      //
      //     <!-- build:css({.tmp,app}) styles/main.css -->
      //
      // dist: {
      //     files: {
      //         '<%= yeoman.dist %>/styles/main.css': [
      //             '.tmp/styles/{,*/}*.css',
      //             '<%= yeoman.app %>/styles/{,*/}*.css'
      //         ]
      //     }
      // }
    },
    htmlmin: {
      dist: {
        options: {
          /*removeCommentsFromCDATA: true,
            // https://github.com/yeoman/grunt-usemin/issues/44
            //collapseWhitespace: true,
            collapseBooleanAttributes: true,
            removeAttributeQuotes: true,
            removeRedundantAttributes: true,
            useShortDoctype: true,
            removeEmptyAttributes: true,
            removeOptionalTags: true*/
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>',
          src: '*.html',
          dest: '<%= yeoman.dist %>'
        }]
      }
    },
    // Put files not handled in other tasks here
    copy: {
      js_css_fonts_to_tmp: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>',
          dest: '<%= yeoman.tmp %>',
          src: [
            '**/*.{js,css,html,svg,eot,ttf,woff}'
          ]
        }]
      },
      html_fonts_to_dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.tmp %>',
          dest: '<%= yeoman.dist %>',
          src: [
            '**/*.{html,svg,ttf,eot,woff}'
          ]
        }]
      }
    }
  });

  grunt.registerTask('serve', function (target) {
    if (target === 'dist') {
      return grunt.task.run(['build', 'connect:dist:keepalive']);
    }

    grunt.task.run([
      'clean',
      'copy:js_css_fonts_to_tmp',
      'compass',
      'coffee',
      'connect:livereload',
      'watch'
    ]);
  });

  grunt.registerTask('build', [
    'clean',
    'copy:js_css_fonts_to_tmp',
    'compass',
    'coffee',
    'useminPrepare',
    'concat',
    'cssmin',
    'uglify',
    'copy:html_fonts_to_dist',
    'usemin'
  ]);

  grunt.registerTask('default', [
    'serve'
  ]);
};
