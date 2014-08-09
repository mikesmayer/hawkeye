var item_sales_breakdown_granulatrity;
var item_sales_index_date_range;
var selected_restaurant;


function init_item_sales_index(){
	item_sales_breakdown_granulatrity = "day";
	item_sales_index_date_range = "current_week";
	selected_restaurant = "p42";

	update_aggregate_item_sales_breakdown();
	update_sales_info_boxes();
	
	item_sales_setup_click_handlers();

	update_category_sales_chart();
}

function item_sales_update_date_range(){
	console.log("item_sales_update_date_range");
	
	update_aggregate_item_sales_breakdown();
	update_sales_info_boxes();
	update_item_sales_details();

	update_details_csv_download_url();
	update_category_sales_chart();
}

function update_restaurant_selection(){
	console.log("update restaurant" + selected_restaurant);
	update_sales_info_boxes();
	update_item_sales_details();
	update_aggregate_item_sales_breakdown();
	
	update_details_csv_download_url();
	update_category_sales_chart();

}



/*
function update_aggregate_item_sales_breakdown(){


	$('#aggregate-item-sales-table').dataTable({
		"bDestroy": true,
	  	"sPaginationType": "bootstrap",
	    "processing": true,
	    "serverSide": true,
	    "ajax": "http://localhost:3000/item_sales/aggregate_items.json?granularity="+item_sales_breakdown_granulatrity,
	    "pagingType": "simple",
	    "stateSave": true,
	    "bFilter": false
	});

	
}
*/

function update_aggregate_item_sales_breakdown(){

	$.ajax({
	  url: "item_sales/aggregate_items",
	  type: "GET", 
	  data: { 
	  	granularity: item_sales_breakdown_granulatrity,
	  	date_range: item_sales_index_date_range,
	  	restaurant: selected_restaurant
	  }, 
	  cache: false,
	  beforeSend: function() {
		$('#aggreage_loading_spinner').show();	
		$('#aggregate_tbl_container').hide();

	  },
	  success: function(html) {
	    //console.log("meals/detail_counts?" + breakdown_tbl_granularity);

		$('#aggregate-item-sales-table').dataTable({
			"sPaginationType": "bootstrap",
			"bFilter": false
		});
		
		$('#aggreage_loading_spinner').hide();	
		$('#aggregate_tbl_container').show();

	  }
	});

}

function update_sales_info_boxes(){
	$.ajax({
		url: "item_sales/sales_totals",
		cache: false,
		data: {
			date_range: item_sales_index_date_range,
			restaurant: selected_restaurant
		},
		beforeSend: function(){
			//$('#loading_spinner_date_picker').show();
			
		},
		success: function(data){
			//$('#loading_spinner_date_picker').hide();
			console.log(data);
			net_sales = addCommas( data.net_sales.toFixed(0) );
			discount_totals = addCommas( data.discount_totals.toFixed(0) );
			m4m_totals = addCommas( data.m4m_totals.toFixed(0) );
			food_totals = addCommas( data.food_sales.toFixed(0) );
			merch_totals = addCommas( data.merch_sales.toFixed(0) );

			$('#net_sales_info_box').html("$" + net_sales);
			$('#discounts_info_box').html("$" + discount_totals);
			$('#m4m_info_box').html(m4m_totals);
			$('#food_sales_info_box').html("$" + food_totals);
			$('#merch_sales_info_box').html("$" + merch_totals);
		}
	});	
}


function update_category_sales_chart(){
	$.ajax({
		url: "item_sales/category_totals",
		type: "GET",
		cache: false,
		data: {
			date_range: item_sales_index_date_range,
			restaurant: selected_restaurant
		},
		beforeSend: function(){
			$('#chart1_cont').hide();
		},
		success: function(data){
			console.log("Updating category sales chart");
			console.log(data);
			
			var columns = data.columns;
			var series_data = data.totals;
			var total = data.all_cat_total;
			var series = [{
				data: series_data
			}];
			console.log(columns);
			console.log(series);
			

			if( total > 0.01){
				$('#chart1_cont').show();
				setupCategoryChart(columns, series, total);
			}
			
			
			
		}
	});


	//var columns = ['Africa', 'America', 'Asia', 'Europe', 'Oceania'];
	/*var series = [{
            data: [107, 31, 635, 203, 2]
        }];
        */

	
}

function setupCategoryChart(columns, series, total){
	$('#category_chart').highcharts({
        chart: {
            type: 'bar'
        },
        title: {
            text: null
        },/*
        subtitle: {
            text: 'Source: Wikipedia.org'
        },*/
        xAxis: {
            categories: columns,
            title: {
                text: null
            }
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Net Sales'
            },
            labels: {
                overflow: 'justify'
            }
        },
        tooltip: {
            formatter: function() {
                return '<b>'+ this.x +'</b><br/>'+
                '$'+ addCommas(this.y) + '<br/>' +
                'Percent of total: ' + ((this.y/total)*100).toFixed(2) + '%';
            }
        },
        plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true,
                    formatter: function() {
                    	return '$' + addCommas(this.y);
                    }
                }
            }
        },
        legend: {
        	enabled: false
            /*
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'top',
            x: -40,
            y: 100,
            floating: true,
            borderWidth: 1,
            backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor || '#FFFFFF'),
            shadow: true
            */
        },
        credits: {
            enabled: false
        },
        series: series
    });
}

function item_sales_setup_click_handlers(){

	/* Click handlers for granulatrity on Counts breakdown table */
	$('#breakdown_by_day_selector').click(function(){
		item_sales_breakdown_granulatrity = "day";
		update_aggregate_item_sales_breakdown();
	});

	$('#breakdown_by_month_selector').click(function(){
		item_sales_breakdown_granulatrity = "month";
		update_aggregate_item_sales_breakdown();
	});

	$('#breakdown_by_quarter_selector').click(function(){
		item_sales_breakdown_granulatrity = "quarter";
		update_aggregate_item_sales_breakdown();
	});

	$('#breakdown_by_year_selector').click(function(){
		item_sales_breakdown_granulatrity = "year";
		update_aggregate_item_sales_breakdown();
	});
	/* end counts breakdown table granulatrity callback handlers */



	/* click hanlders for page date scope */
	$('#date_filter_all_time').click(function(){
		$('#custom_range_input').hide();
		item_sales_index_date_range = "all";
		item_sales_update_date_range();
	});

	$('#date_filter_current_year').click(function(){
		$('#custom_range_input').hide();
		item_sales_index_date_range = "current_year";
		item_sales_update_date_range();
	});

	$('#date_filter_current_month').click(function(){
		$('#custom_range_input').hide();
		item_sales_index_date_range = "current_month";
		item_sales_update_date_range();
	});

	$('#date_filter_current_week').click(function(){
		$('#custom_range_input').hide();
		item_sales_index_date_range = "current_week";
		item_sales_update_date_range();
	});


	$('#date_filter_daterange').click(function(){
		$('#custom_range_input').show();
	});


	$('#date_range_filter_btn').click(function(){
		var start_range = $('#date_range_start').val();
		var end_range = $('#date_range_end').val();
		console.log("start" + start_range);
		console.log("end" + end_range);
		item_sales_index_date_range = start_range + "T" + end_range;
		console.log(date_range);
		item_sales_update_date_range();
	});
	/* end click handlers for page date scope */


	/* click handlers for restaurant selection */
	$('#p42_selector').click(function(){
		selected_restaurant = "p42";
		update_restaurant_selection();
	});

	$('#tacos_selector').click(function(){
		selected_restaurant = "tacos";
		update_restaurant_selection();
	});

	/* end click handlers for restaurant selection */

}