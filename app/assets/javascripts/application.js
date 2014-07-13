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

	$('#daterange').popover({
		html: true,
		content: "Test Content",
		placement: "bottom",
		container: "#daterange"
	});

	/* START JS for the meals index page */
	if( $('#meals_index_page').length > 0 ){


		update_count_breakdown("day");


		$.ajax({
			url: "meals/month_counts",
			cache: false,
			success: function(html){
				console.log("meals/month_counts");
			}
		});

		$.ajax({
			url: "meals/year_counts",
			cache: false,
			success: function(html){
				console.log("meals/year_counts")
			}
		});

		$('#breakdown_by_day_selector').click(function(){
			console.log("day selected");
			update_count_breakdown("day");
		});

		$('#breakdown_by_month_selector').click(function(){
			console.log("month selected");
			update_count_breakdown("month");
		});

		$('#breakdown_by_quarter_selector').click(function(){
			console.log("quarter selected");
			update_count_breakdown("quarter");
		});

		$('#breakdown_by_year_selector').click(function(){
			console.log("year selected");
			update_count_breakdown("year");
		});
	}
	/* END meals index page specific js */

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

});


function update_count_breakdown(selected_granularity){
	console.log(selected_granularity);
		

	$.ajax({
	  url: "meals/detail_counts",
	  type: "GET", 
	  data: { granularity: selected_granularity }, 
	  cache: false,
	  beforeSend: function() {
		$('#count_ajax_loading').show();	
		$('#detail_tbl_container').hide();

	  },
	  success: function(html) {
	    console.log("meals/detail_counts?" + selected_granularity);

		$('#m4m_stats_tbl').dataTable({
		  "sPaginationType": "bootstrap"
		});
		console.log('test');
		$('#count_ajax_loading').hide();	
		$('#detail_tbl_container').show();

	  }
	});

}

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
