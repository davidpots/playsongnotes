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
  $('.js-summonScalePicker').click(function(){
    $('.js-scalePicker').fadeIn('fast');
    return false;
  });

  // to launch scale picker overlay
  $('.js-summonKeyPicker').click(function(){
    $('.js-keyPicker').fadeIn('fast');
    return false;
  });

  $('.keyChangeFwd').click(function(){
    if ( $('.js-keySelector .active').attr('data-key-name') == "G#" ) {
      $('.js-keySelector li a[data-key-name="A"]').trigger('click');
    } else {
      $('.js-keySelector .active').parent('li').next('li').find('a').trigger('click');
    }
    return false;
  });

  $('.keyChangePrev').click(function(){
    if ( $('.js-keySelector .active').attr('data-key-name') == "A" ) {
      $('.js-keySelector li a[data-key-name="G#"]').trigger('click');
    } else {
      $('.js-keySelector .active').parent('li').prev('li').find('a').trigger('click');
    }
    return false;
  });

  $(window).bind('keydown', function(e){
    if(e.which == 39) {
      // right
      $('.keyChangeFwd').trigger('click');
      return false;
    }
    if(e.which == 37) {
      // left
      $('.keyChangePrev').trigger('click');
      return false;
    }
    if(e.which == 221) {
      // right
      $('.js-scaleSelector .active').parent('li').next('li').find('a').trigger('click');
      return false;
    }
    if(e.which == 219) {
      // left
      $('.js-scaleSelector .active').parent('li').prev('li').find('a').trigger('click');
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
                $(this).toggleClass('active--toggle');
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
                $(this).toggleClass('active--toggle');
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
                $(this).toggleClass('active--toggle');
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
                $('.note[data-active="true"]').each(function(i,obj){
                  if ( ($(obj).attr('data-interval') == "3") || ($(obj).attr('data-interval') == "5") || ($(obj).attr('data-interval') == "b3") || ($(obj).attr('data-interval') == "1")) {
                    $(this).removeClass('highlight').addClass('noHighlight');
                  }
                  if ( $(obj).attr('data-interval') == "1" ) {
                    $(this).removeClass('highlight').addClass('noHighlight');
                  }
                });
                highlightingRoot = false;
                highlightingTriads = false;
                highlightingNone = true;
                $('.highlightRoot').removeClass('active--toggle');
                $('.highlightTriads').removeClass('active--toggle');
                $(this).addClass('active--toggle');
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



});
