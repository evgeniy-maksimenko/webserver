define([

	'backbone',
	'underscore',
	'modules/workorders/collections/orders',
	'modules/workorders/views/item',
	'layouts/layoutBasic/layout',
	'text!modules/workorders/templates/listTemplate.html',
	'router',

],function(Backbone, _, OrdersCollection, OrderView, Layout, listTemplate, router) {
	
	var DEF_STATUS 		= 'WORK';
	var CLOSED_STATUS   = 'CLOSED';
	
	var range;
	var datepickerRangeOptions = {
	    maxDate: "+0D",
	    minDate: "-1M",
	    dateFormat: "yy-mm-dd",
	    onSelect: function(selectedDate) {
	        var option = this.id == "fromDate" ? "minDate" : "maxDate",
	                instance = $(this).data("datepicker"),
	                data_datapicker = $.datepicker.parseDate(
	                instance.settings.dateFormat ||
	                $.datepicker._defaults.dateFormat,
	                selectedDate, instance.settings);
	        var edate;
	        var otherOption;
	        var m;
	        if (option == "minDate") {
	            otherOption = "maxDate";
	            m = data_datapicker.getMonth() + 1;
	        } else if (option == "maxDate") {
	            otherOption = "minDate";
	            m = data_datapicker.getMonth() - 1;
	        }
	        var d = data_datapicker.getDate()
	        var y = data_datapicker.getFullYear();
	        edate = new Date(y, m, d);
	        range.not(this).datepicker("option", option, data_datapicker);
	        range.not(this).datepicker("option", otherOption, edate);
	    }
	};

	function fun_change_order_status() {
		var status = $("#order_status").val();
			if(status == CLOSED_STATUS) {
				$("#form_closed_status").show();
				range = $(".date-range").datepicker(datepickerRangeOptions);
				$("#fromDate").val($.cookie('fromDate'));
				$("#toDate").val($.cookie('toDate'));			
				
			} else {
				$("#form_closed_status").hide();
			}
	}

	function init(this_, status, fromDate, toDate) {
		this_.$el.empty();
		if(fromDate && toDate)
		{
			this_.collection = new OrdersCollection(status, fromDate, toDate);
		} else {
			this_.collection = new OrdersCollection(status);
        }
        this_.collection.fetch({
        	reset:true
        });
        this_.render();
       	this_.listenTo(this_.collection, 'reset', this_.render); 

       	return this_;
	};

	var View1 = Backbone.View.extend({
		 
		template: _.template(listTemplate),

		events: {
			'click #btn_refresh' : 'refresh',
			'change #order_status' : 'change_order_status'
		},

		initialize: function() {			 
			$.removeCookie('status'); 
			init(this, DEF_STATUS);
		},
		render: function() {
			var attrs = router.routeArguments();
			this.$el.html(this.template());
			this.collection.each(this.renderOrder, this);
			if(attrs.id) {
				$("#" + attrs.id).click();
			}

			var cookie = $.cookie('status');
			if(cookie) {
				$("#order_status option[value="+cookie+"]").attr('selected', 'selected');
			}
			fun_change_order_status();
			$('.selectpicker').selectpicker();
			return this;
		},
		renderOrder: function(item) {
			var orderView = new OrderView({
            	model: item
	        });
	        $("#orders").append(orderView.render().el);
	        return this;
		},
		refresh: function() {
			var status = $("#order_status").val();
			$.cookie('status', status);
			if( status == CLOSED_STATUS ) {
				var fromDate = $("#fromDate").val();
				var toDate 	 = $("#toDate").val();
				$.cookie('fromDate', fromDate);
				$.cookie('toDate', toDate);
				init(this, status, fromDate, toDate);
			} else {
				init(this, status);
			}
		},
		change_order_status: function() {
			fun_change_order_status();
		}
	});
	
	return Layout.extend({
		content: View1
	});
});
