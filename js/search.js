// via https://learn.cloudcannon.com/jekyll/jekyll-search-using-lunr-js/
  function getQueryVariable(variable) {
    var query = window.location.search.substring(1);
    query = query.replace('&',"%26");
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

    // {% if lessons[i].title %}
    //   {% assign lesson_title = lessons[i].title | replace: '"','\"' %}
    // {% else %}
    //   {% assign lesson_title = "" %}
    // {% endif %}

    // if ( lessons[i].title ) {
    //   lesson_title = lessons[i].title;
    // } else {
    //   lesson_title = "";
    // }


    // The \\b is a RegExp thing that means "word boundary" on either end of the search term.
    //     This ensures that a query for "20" will NOT be true for the tag "2000s", etc
    // The "i" means case insensitive, I believe
    // https://stackoverflow.com/questions/2232934/how-can-i-match-a-whole-word-in-javascript

    if (lessons[i] != null){

      if (
          (lessons[i].title.search(new RegExp("\\b" + searchQueryText + "\\b", 'i')) >= 0) ||
          (lessons[i].category.search(new RegExp("\\b" + searchQueryText + "\\b", 'i')) >= 0) ||
          (lessons[i].slug.search(new RegExp("\\b" + searchQueryText + "\\b")) >= 0) ||
          (lessons[i].tags.search(new RegExp("\\b" + searchQueryText + "\\b", 'i')) >= 0) ||
          (lessons[i].hidden_tags.search(new RegExp("\\b" + searchQueryText + "\\b", 'i')) >= 0)
        ) {

          if ( lessons[i].pdf_version == "musicnotes" ) {
            pdf_badge = "<p class=\"featured_label\" data-pdf-version=\"" + lessons[i].pdf_version + "\" data-patreon-url=\"" + lessons[i].patreon_url + "\">$ PDF</p>";
          } else {
            pdf_badge = "<p class=\"featured_label\" data-pdf-version=\"" + lessons[i].pdf_version + "\" data-patreon-url=\"" + lessons[i].patreon_url + "\">PDF</p>";
          }

        $('#search-results').append('<li class="song-listing"><h3><a href="'+ lessons[i].url +'"><span>'+ lessons[i].title +'</span></a></h3><p>Lesson #'+ lessons[i].slug +' • '+ lessons[i].category +'</p>' + pdf_badge + '</li>');
      }

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
