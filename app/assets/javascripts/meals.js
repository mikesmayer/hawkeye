var breakdown_tbl_granularity;
var date_range;

function init_meals_index(){
	breakdown_tbl_granularity = "day";
	date_range = "all";
	
	update_count_breakdown();
	update_counts_by_month();
	update_counts_by_year();


	/* function that just sets up all of the click handlers for the page */
	setup_click_handlers();



	$('#date_filter_daterange').popover({
		html: true,
		content: "Test Content",
		placement: "bottom",
		container: "#date_filter_daterange"
	});	
}


/* called whenever the date range is changed 
*  this will update:
*  the counts breakdown table (update_count_breakdown() function is called)
*  the counts by month table (update_counts_by_month() function is called)
*  the counts by year table (update_counts_by_year() function is called)
*/
function update_date_range(){
	//console.log("Date range: " + date_range);
	update_count_breakdown();
	update_counts_by_month();
	update_counts_by_year();
	update_meal_info_boxes();
}


function update_count_breakdown(){
	console.log(breakdown_tbl_granularity);
	console.log(date_range);

	$.ajax({
	  url: "meals/detail_counts",
	  type: "GET", 
	  data: { 
	  	granularity: breakdown_tbl_granularity,
	  	date_range: date_range
	  }, 
	  cache: false,
	  beforeSend: function() {
		$('#count_detail_body_container').show();	
		$('#detail_tbl_container').hide();

	  },
	  success: function(html) {
	    //console.log("meals/detail_counts?" + breakdown_tbl_granularity);

		$('#m4m_stats_tbl').dataTable({
		  "sPaginationType": "bootstrap"
		});
		
		$('#count_detail_body_container').hide();	
		$('#detail_tbl_container').show();

	  }
	});

}


function update_counts_by_month(){
	$.ajax({
		url: "meals/month_counts",
		cache: false,
		data: {
			date_range: date_range 
		},
		beforeSend: function(){
			$('#count_month_body_container').show();
			$('#m4m_month_container').hide();
		},
		success: function(html){
			$('#count_month_body_container').hide();
			$('#m4m_month_container').show();

			//console.log("meals/month_counts");
			
			$('#m4m_month_tbl').dataTable({
			  "sPaginationType": "bootstrap",
			  "pagingType": "simple",
			  "ordering": false,
			  "bFilter": false,
			  "bLengthChange": false
			});
		}
	});
}


function update_counts_by_year(){
	$.ajax({
		url: "meals/year_counts",
		cache: false,
		data: {
			date_range: date_range 
		},
		beforeSend: function(){
			$('#count_year_body_container').show();
			$('#m4m_year_container').hide();
		},
		success: function(html){
			$('#count_year_body_container').hide();
			$('#m4m_year_container').show();
			//console.log("meals/year_counts")
		}
	});	
}


function update_meal_info_boxes(){
	$.ajax({
		url: "meals/count_totals",
		cache: false,
		data: {
			date_range: date_range 
		},
		beforeSend: function(){
			$('#loading_spinner_date_picker').show();
			
		},
		success: function(data){
			$('#loading_spinner_date_picker').hide();
			console.log(data);
			total = addCommas( data.total.toFixed(0) );
			m4m = addCommas( data.m4m.toFixed(0) );
			dym = addCommas( data.dym.toFixed(0) );
			apparel = addCommas( data.apparel.toFixed(0) );
			tip_jar = addCommas( data.tip_jar.toFixed(0) );

			$('#total_meals_info_box').html(total);
			$('#m4m_meals_info_box').html(m4m);
			$('#dym_meals_info_box').html(dym);
			$('#apparel_meals_info_box').html(apparel);
			$('#tip_jar_meals_info_box').html(tip_jar);
		}
	});	
}



function setup_click_handlers(){
	/* Click handlers for granulatrity on Counts breakdown table */
	$('#breakdown_by_day_selector').click(function(){
		breakdown_tbl_granularity = "day";
		update_count_breakdown();
	});

	$('#breakdown_by_month_selector').click(function(){
		breakdown_tbl_granularity = "month";
		update_count_breakdown();
	});

	$('#breakdown_by_quarter_selector').click(function(){
		breakdown_tbl_granularity = "quarter";
		update_count_breakdown();
	});

	$('#breakdown_by_year_selector').click(function(){
		breakdown_tbl_granularity = "year";
		update_count_breakdown();
	});
	/* end counts breakdown table granulatrity callback handlers */


	/* click hanlders for page date scope */
	$('#date_filter_all_time').click(function(){
		date_range = "all";
		update_date_range();
	});

	$('#date_filter_current_year').click(function(){
		date_range = "current_year";
		update_date_range();
	});

	$('#date_filter_current_month').click(function(){
		date_range = "current_month";
		update_date_range();
	});

	$('#date_filter_current_week').click(function(){
		date_range = "current_week";
		update_date_range();
	});

	$('#daet_filter_daterange').click(function(){
		date_range = "custom";
		update_date_range();
	});
	/* end click handlers for page date scope */

}

function addCommas(nStr) {
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
}