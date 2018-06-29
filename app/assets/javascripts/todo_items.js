function isValidPlacement() {
  //check that all important tasks are on top
  var endOfImportantGroup = false
  var isValid = true
  var $items = $('#todos').find('.list-group-item')
  
  $.each($items, function(index, item) {
    // console.log(item)
    // console.log($(item))
    if (!$(item).hasClass('important') && !endOfImportantGroup) {
      endOfImportantGroup = true
    } else if ($(item).hasClass('important') && endOfImportantGroup) {
      isValid = false
    }
  })
  return isValid
}

document.addEventListener("turbolinks:load", function() {
  $("#todos").sortable({
    update: function(e, ui) {
      console.log("isValidPlacement", isValidPlacement())
      if (isValidPlacement()) {
        $.ajax({
          url: $(this).data('url'),
          type: 'PATCH',
          data: $(this).sortable('serialize')
        })
      }
    },
    stop: function(e, ui){
      // check if importance clashes
      if(!isValidPlacement()) {
        $("#todos").sortable('cancel')
      }
    }
  })
})