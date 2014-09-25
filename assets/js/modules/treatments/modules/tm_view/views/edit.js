define([
	'backbone',
	'layouts/layoutBasic/layout',
	'text!modules/treatments/modules/tm_view/templates/editTemplate.html',
	'router',
	'modules/treatments/modules/tm_view/collections/treatment',
	'text!templates/forbiddenTemplate.html',
], function(Backbone, Layout, editTemplate, router, Collection, forbiddenTemplate) {

	function getData(attrs) {
	    var data = 
	        $.ajax({
	            url : '/api/treatments?id='+attrs.id+'&condition=view',
	            type: "POST",
	            dataType: "json",
	            async: false,
	            success: function(data){}
	        });
	    return data;
	};

	var EditPage = Backbone.View.extend({
		template: _.template(editTemplate),
		forbiddenTpl: _.template(forbiddenTemplate),
		events: {
			'click .rating' : 'saveRating' 
		},
		render: function() {
			var attrs = router.routeArguments();
			var data  = getData(attrs);
			if((data.status == 403) || (data.status == 400))
			{
				this.$el.html(this.forbiddenTpl(this));	
			}
			else
			{
				var arrayData =data.responseJSON;
				this.$el.html(this.template(arrayData[0]));
			}			
			return this;
		},
		saveRating: function(btn) {			
			var attrs = router.routeArguments();
			var rating = $(btn.currentTarget).attr('id');
			$.ajax({
	            url : '/api/treatments?condition=rating&id='+attrs.id,
	            type: "POST",
	            dataType: "json",
	            data: 'rating='+rating,
	            success: function(){
	            	$("#ratingRequest").empty().text('Спасибо за ответ');		              
	            }
	        });
		}
	});

	return EditPage;
});