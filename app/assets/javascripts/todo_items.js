function isValidPlacement() {
  //check that all important tasks are on top
  var endOfImportantGroup = false
  var isValid = true
  var $items = $('#todos').find('.list-group-item')

  $.each($items, function(index, item) {
    if (!$(item).hasClass('important') && !endOfImportantGroup) {
      endOfImportantGroup = true
    } else if ($(item).hasClass('important') && endOfImportantGroup) {
      isValid = false
    }
  })
  return isValid
}

function setListItemContent($listItem) {
  $listItem.toggleClass('list-group-item-primary').toggleClass('important')
  $listItem.find('a').toggleClass('btn-info').toggleClass('btn-warning')
  $listItem.hasClass('important') ? $listItem.find('a').text('Mark Unimportant') : $listItem.find('a').text('Mark Important')
}

function handleToggleImportant(e) {
  e.preventDefault()
  console.log('toggle important')

  var $listItem = $(this).parent()
  $.ajax({
    method: 'patch',
    url: this.href
  }).done(function(data) {
    console.log(data)
    console.log($listItem)
    setListItemContent($listItem)
    if(data.is_important) {
      // move to top
      $listItem.prependTo('#todos')
    } else {
      $listItem.appendTo('#todos')
    }
  })
}

function handleToggleCompleted() {
  console.log('here')
}

document.addEventListener("turbolinks:load", function() {
  $("#todos").sortable({
    update: function(e, ui) {
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

  $('.list-group-item').on('change', 'input[type="checkbox"]', handleToggleCompleted)
  $('.list-group-item').on('click', '.toggle-important', handleToggleImportant)
})