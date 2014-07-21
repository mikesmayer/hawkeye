// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require bootstrap-datepicker
//= require 'rest_in_place'
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require_tree .


$(document).ready(function(){
	var nowTemp = new Date();
	var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
	

/*
	var recipe_tbl = $('#menu_items_tbl').dataTable({
		"sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
		"sPaginationType": "bootstrap",
		"bRetrieve": true,
		"aoColumnDefs": [
			{ 'bSortable': false, 
				'aTargets': [ 7, 8, 9 ] }
		]
	});
*/
	$('.datepicker').datepicker({
		format: 'yyyy/mm/dd',
		//endDate: '-1d',
		autoclose: false
	});



	/* JS for the meals index page */
	if( $('#meals_index_page').length > 0 ){
		//function found in meals.js
		init_meals_index();	
	}


	if( $('#gdrive_file_list').length > 0 ){
		console.log("Getting files from google drive");
		$.ajax({
			url: "ticket_items/file_list",
			cache: false,
			success: function(html){
				console.log(html);
				$('#gdrive_file_list').html(html);
			}
		});
	}

	/* Only used on menu item group index page right now */
	$('.rest-in-place').each(function(i, obj){
		$(this).bind('failure.rest-in-place', function(event, json){
			var error_count_html = "<div class=\"alert alert-danger fade in\">";
			error_count_html += "Failed to update default meal number. Please enter an integer.";
			error_count_html += "<button type=\"button\"";
			error_count_html += "class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">x</button></div>";
			$('#error_cont').html(error_count_html);
			$(".alert").alert();
		});
	});



	/* these binds are used in error handling for the ajax modals used throughout the site */
	$(document).bind('ajaxError', 'form#new_p42_meal_count_rule', function(event, jqxhr, settings, exception){
		// note: jqxhr.responseJSON undefined, parsing responseText instead
		$(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
	});

	$(document).bind('ajaxError', 'form.edit_p42_meal_count_rule', function(event, jqxhr, settings, exception){
		// note: jqxhr.responseJSON undefined, parsing responseText instead
		$(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
	});


	$('#tip_jar_stats_tbl').dataTable({
	  "sPaginationType": "bootstrap",
	  "order": [2, 'desc'],
	  "columnDefs": [
	  	{ "orderable": false, "targets": [ 4, 5, 6 ] }
	  ]
	});

});



(function($) {

  $.fn.modal_success = function(){
    // close modal
    this.modal('hide');

    // clear form input elements
    // todo/note: handle textarea, select, etc
    this.find('form input[type="text"]').val('');
    this.find('form input[type="number"]').val('');

    // clear error state
    this.clear_previous_errors();
  };

  $.fn.render_form_errors = function(errors){

    $form = this;
    this.clear_previous_errors();
    model = this.data('model');

    // show error messages in input form-group help-block
    $.each(errors, function(field, messages){
      $input = $('input[name="' + model + '[' + field + ']"]');
      $input.closest('.form-group').addClass('has-error').find('.help-block').html( messages.join(' & ') );
    });

  };

  $.fn.clear_previous_errors = function(){
    $('.form-group.has-error', this).each(function(){
      $('.help-block', $(this)).html('');
      $(this).removeClass('has-error');
    });
  }

}(jQuery));
