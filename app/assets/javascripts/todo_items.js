document.addEventListener("turbolinks:load", function() {
  $("#todos").sortable({
    update: function(e, ui) {
      $.ajax({
        url: $(this).data('url'),
        type: 'PATCH',
        data: $(this).sortable('serialize')
      })
    }
  })
})