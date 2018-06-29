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

function formatListItemContentForImportant($listItem) {
  $listItem.toggleClass('list-group-item-primary').toggleClass('important')
  $listItem.find('a').toggleClass('btn-info').toggleClass('btn-warning')
  $listItem.hasClass('important') ? $listItem.find('a').text('Mark Unimportant') : $listItem.find('a').text('Mark Important')
}

function formatListItemContentForCompleted($listItem) {
  $listItem.removeClass('list-group-item-primary').addClass('list-group-item-light')
  $listItem.find('a.toggle-important').remove()
  $listItem.find('input[type = "checkbox"]').remove()
  $listItem.find('span.move').remove()
}

function handleToggleImportant(e) {
  e.preventDefault()

  var $listItem = $(this).parent()
  $.ajax({
    method: 'patch',
    url: this.href
  }).success(function(data) {
    if(data.is_important) {
      // move to top
      $listItem.prependTo('#todos')
    } else {
      $listItem.appendTo('#todos')
    }
    formatListItemContentForImportant($listItem)
  }).fail(function(data){
    alert('Something went wrong. Please try again.')
  })
}

function handleToggleCompleted() {
  var $listItem = $(this).parent()
  $.ajax({
    method: 'patch',
    url: $(this).data('url')
  }).success(function (data) {
    $listItem.appendTo('#completedTodoItems')
    formatListItemContentForCompleted($listItem)
  }).fail(function (data) {
    alert('Something went wrong. Please try again.')
  })
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
    },
    handle: '.move'
  })

  $('.list-group-item').on('change', 'input[type="checkbox"]', handleToggleCompleted)
  $('.list-group-item').on('click', '.toggle-important', handleToggleImportant)
})