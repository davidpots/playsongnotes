// via https://learn.cloudcannon.com/jekyll/jekyll-search-using-lunr-js/
  function getQueryVariable(variable) {
    var query = window.location.search.substring(1);
    var vars = query.split('&');
    for (var i = 0; i < vars.length; i++) {
      var pair = vars[i].split('=');

      if (pair[0] === variable) {
        return decodeURIComponent(pair[1].replace(/\+/g, '%20'));
      }
    }
  }
  var searchTerm = getQueryVariable('query');



function updateSearchHeading() {
  $('#numResultsFound').html( $('#search-results li').length);
  $('#searchQuery').text("\"" + searchQueryText + "\"");
  $('#yesQueryPrompt').show();
}


function runSearch(searchTerm) {

  // Get search query term...
  searchQueryText = searchTerm;

  // Go through all items...
  for (i = 0; i < latest_lesson_number; i++) {

    if (
        (lessons[i].title.search(new RegExp(searchQueryText, 'i')) >= 0) || (lessons[i].category.search(new RegExp(searchQueryText, 'i')) >= 0) || (lessons[i].slug.search(new RegExp(searchQueryText, 'i')) >= 0)
      ) {

      $('#search-results').append('<li class="song-listing"><h3><a href="'+ lessons[i].url +'"><span>'+ lessons[i].title +'</span></a></h3><p>Lesson #'+ lessons[i].slug +' • '+ lessons[i].category +'</p><p class="featured_label" data-patreon-url="' + lessons[i].patreon_url + '">PDF</p></li>');
    }
      // If this item has search term in TITLE or SLUG or CATEGORY, display it
  }
  // updateSearchHeading();
  // $('#numResultsFound').html("dog man dude");
}







$(document).ready(function(){
  if (searchTerm) {
    $('#noQueryPrompt').hide();
    document.getElementById('search-box').setAttribute("value", searchTerm);
    runSearch(searchTerm);
  } else {
    $('#noQueryPrompt').show();
  }
});
