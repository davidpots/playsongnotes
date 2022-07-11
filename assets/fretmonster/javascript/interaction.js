$(document).ready(function(){

  // Sets up size for the overlays
  $('.js-overlay').css('position', 'fixed')
  var el = $('.js-overlay');
  $(el).height( $(window).height());

  // close the overlays
  $('.js-closeOverlay').click(function(){
    $(this).closest('.js-overlay').hide();
  });
  $('body').click(function(){
    $('.js-overlay.fixed').hide();
  });



  // to launch scale picker overlay
  $('.prompt_picker__scale').click(function(){
    $('.js-scaleSelector').fadeIn('fast');
    return false;
  });

  // to launch scale picker overlay
  $('.prompt_picker__key').click(function(){
    $('.js-keySelector').fadeIn('fast');
    return false;
  });

  // if user clicks NEXT KEY arrow
  $('.prompt_picker__key__next').click(function(){
    changeKeyNext();
    return false;
  });

  // if user clicks PREV KEY arrow
  $('.prompt_picker__key__prev').click(function(){
    changeKeyPrev();
    return false;
  });

  function changeScaleNext(){
    if ( $('.js-scaleSelector .active').attr('data-scale-name') == "chromatic" ) {
      $('.js-scaleSelector a[data-scale-name="major"]').trigger('click');
    } else {
      $('.js-scaleSelector .active').next('a').trigger('click');
    }
  }
  function changeScalePrev(){
    if ( $('.js-scaleSelector .active').attr('data-scale-name') == "major" ) {
      $('.js-scaleSelector a[data-scale-name="chromatic"]').trigger('click');
    } else {
      $('.js-scaleSelector .active').prev('a').trigger('click');
    }
  }

  function changeKeyNext(){
    if ( $('.js-keySelector .active').attr('data-key-name') == "G#" ) {
      $('.js-keySelector a[data-key-name="A"]').trigger('click');
    } else {
      // $('.js-keySelector .active').parent('li').next('li').find('a').trigger('click');
      $('.js-keySelector .active').next('a').trigger('click');
    }
  }
  function changeKeyPrev(){
    if ( $('.js-keySelector .active').attr('data-key-name') == "A" ) {
      $('.js-keySelector a[data-key-name="G#"]').trigger('click');
    } else {
      // $('.js-keySelector .active').parent('li').prev('li').find('a').trigger('click');
      $('.js-keySelector .active').prev('a').trigger('click');
    }
  }

  $(window).bind('keydown', function(e){
    if(e.which == 39) {
      // right arrow
      changeKeyNext();
      return false;
    }
    if(e.which == 37) {
      // left arrow
      changeKeyPrev();
      return false;
    }
    if(e.which == 221) {
      // right bracket
      changeScaleNext();
      return false;
    }
    if(e.which == 219) {
      // left bracket
      changeScalePrev();
      return false;
    }
  });


});

$(window).on('load', function(){

  // Lets the user tweak or toggle some misc display options.

          // Notes-Interval toggle

              $('.showNotes').click(function(){
                var replaceWith;
                $('.note[data-active="true"]').each(function(i,obj){
                  replaceWith = $(obj).data('note');
                  $(obj).text(replaceWith);
                });
                showingNotes = true;
                showingIntervals = false;
                showingNoLabel = false;
                $('.showIntervals').removeClass('active--toggle');
                $('.showNoLabel').removeClass('active--toggle');
                $(this).addClass('active--toggle');
                return false;
              });

              $('.showIntervals').click(function(){
                var replaceWith;
                $('.note[data-active="true"]').each(function(i,obj){
                  replaceWith = $(obj).data('interval');
                  $(obj).text(replaceWith);
                });
                showingNotes = false;
                showingIntervals = true;
                showingNoLabel = false;
                $('.showNotes').removeClass('active--toggle');
                $('.showNoLabel').removeClass('active--toggle');
                $(this).addClass('active--toggle');
                return false;
              });

              $('.showNoLabel').click(function(){
                var replaceWith;
                $('.note[data-active="true"]').each(function(i,obj){
                  replaceWith = $(obj).data('noLabel');
                  $(obj).text('');
                });
                showingNotes = false;
                showingIntervals = false;
                showingNoLabel = true;
                $('.showNotes').removeClass('active--toggle');
                $('.showIntervals').removeClass('active--toggle');
                $(this).addClass('active--toggle');
                return false;
              });

          // Triads-Root toggle

              $('.highlightRoot').click(function(){
                $('.note[data-active="true"]').each(function(i,obj){
                  if ( ($(obj).attr('data-interval') == "3") || ($(obj).attr('data-interval') == "5") || ($(obj).attr('data-interval') == "b3") ) {
                    $(this).removeClass('highlight');
                  }
                  if ( $(obj).attr('data-interval') == "1" ) {
                    $(this).addClass('highlight').removeClass('noHighlight');
                  }
                });
                highlightingRoot = true;
                highlightingTriads = false;
                highlightingNone = false;
                $('.highlightTriads').removeClass('active--toggle');
                $('.highlightNone').removeClass('active--toggle');
                $(this).addClass('active--toggle');
                return false;
              });

              $('.highlightTriads').click(function(){
                $('.note[data-active="true"]').each(function(i,obj){
                  if ( ($(obj).attr('data-interval') == "3") || ($(obj).attr('data-interval') == "5") || ($(obj).attr('data-interval') == "b3") || ($(obj).attr('data-interval') == "1")) {
                    $(this).addClass('highlight').removeClass('noHighlight');
                  }
                });
                highlightingRoot = false;
                highlightingNone = false;
                highlightingTriads = true;
                $('.highlightRoot').removeClass('active--toggle');
                $('.highlightNone').removeClass('active--toggle');
                $(this).addClass('active--toggle');
                return false;
              });

              $('.highlightNone').click(function(){
                // Moved this to its own function (other file) so I could solve a bug about highlight "none" not sticking
                highlightNone();
                return false;
              });

          // Instrument changer

              $('.instrumentGuitar').click(function(){

              });

              // Bass: remove top two strings
              $('.instrumentBass').click(function(){
                for (var i = 0; i < 2; i++) {
                  $('.string').eq(i).hide();
                  $('.string').eq(i+1).find('.fret--hasBG').css('border','none');
                  $('.string').eq(i+1).find('.fret--open').css('border','none');
                }
                return false;
              });



              // Key Changer!

                      $('.js-keySelector a').click(function(){
                        $('.js-keySelector a').removeClass('active');
                        $(this).addClass('active');
                        var newKey = $(this).attr('data-key-name');
                        currentKey = newKey;
                        computeScaleTones(currentScale.pattern,newKey,fretboardLength);
                        addTonesToFretboard();

                        // Put into function
                        $('.prompt_picker__key__itself').text(newKey);
                        $(this).closest('.fretMonster_picker_popup').hide();

                        // if ( highlightingNone == true ) {
                        //   $('.highlightNone').toggle('click');
                        // }

                        return false;
                      })

              // Scale Changer!

                      $('.js-scaleSelector a').click(function(){
                        $('.js-scaleSelector a').removeClass('active');
                        $(this).addClass('active');
                        var newScale = $(this).attr('data-scale-name');
                        currentScale = scales[newScale];
                        computeScaleTones(scales[newScale].pattern,currentKey,fretboardLength);
                        addTonesToFretboard();

                        // Check for rare chords w/ wacky intervals. Make into function?
                            // Lydian
                            if (newScale == 'lydian_mode') {
                              $('.note[data-interval="b5"]').attr('data-interval','4#');
                              if ( showingIntervals == true ) {
                                $('.note[data-interval="b5"]').text('4#');
                              }
                            }

                        // Put into function
                        $('.prompt_picker__scale').text(scales[newScale].name);
                        $(this).closest('.fretMonster_picker_popup').hide();
                        return false;
                      })

              // Instrument Changer!

                      $('.js-instrumentSelector a').click(function(){
                        $('.js-instrumentSelector a').removeClass('active--toggle');
                        $(this).addClass('active--toggle');
                        var newInstrument = $(this).data('instrument'); // e.g., 'ukulele'
                        if (currentInstrument.name != newInstrument) {
                          currentInstrument = instruments[newInstrument];
                          generateFretboard();
                          computeScaleTones(currentScale.pattern,currentKey,fretboardLength);
                          addTonesToFretboard();
                        }
                        return false;
                      });

      // Close popups if you click off

      $('body').click(function(){
        $('.fretMonster_picker_popup').hide();
      });


      // For hiding string notes
      $(document).on("click", ".stringLabel--1", function() {
        $(this).toggleClass('stringLabel--hidden');
        $('.stringNum--1').toggleClass('stringNum--hidden');
      })
      $(document).on("click", ".stringLabel--2", function() {
        $(this).toggleClass('stringLabel--hidden');
        $('.stringNum--2').toggleClass('stringNum--hidden');
      })
      $(document).on("click", ".stringLabel--3", function() {
        $(this).toggleClass('stringLabel--hidden');
        $('.stringNum--3').toggleClass('stringNum--hidden');
      })
      $(document).on("click", ".stringLabel--4", function() {
        $(this).toggleClass('stringLabel--hidden');
        $('.stringNum--4').toggleClass('stringNum--hidden');
      })
      $(document).on("click", ".stringLabel--5", function() {
        $(this).toggleClass('stringLabel--hidden');
        $('.stringNum--5').toggleClass('stringNum--hidden');
      })
      $(document).on("click", ".stringLabel--6", function() {
        $(this).toggleClass('stringLabel--hidden');
        $('.stringNum--6').toggleClass('stringNum--hidden');
      })


});
