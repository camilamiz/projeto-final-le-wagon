$(document).ready(function() {
  $("#exampleFormControlSelect1").select2({
  });

  $("#exampleFormControlSelect1").change(function() {
    var valSelected = $("#exampleFormControlSelect1").val();

    $("#exampleFormControlSelect1 option").map(function(element) {
      if ($(this).val() === valSelected) {
        var id = $(this).data('id');
        window.location = window.location.origin + "/councillors/" + id
      }
    });


  })
})
