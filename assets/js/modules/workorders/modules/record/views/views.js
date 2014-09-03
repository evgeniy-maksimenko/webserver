define([

	'backbone',
	'text!modules/workorders/modules/record/templates/viewsTemplate.html',
	'router',
	'modules/workorders/modules/record/collections/record',
	'modules/workorders/modules/record/views/view',
	'views/notFound'

],function(Backbone, viewTemplate, router, CollectionRecord, RecordView, PageNotFound){

	var ViewPage = Backbone.View.extend({
		
		template: _.template(viewTemplate),
		initialize: function() {
			var attrs = router.routeArguments();
			this.collection = new CollectionRecord(attrs);
			this.collection.fetch({
				reset:true
			});
			this.listenTo(this.collection, 'reset', this.render); 
			return this;
		},
		render: function() {
			this.$el.html(this.template(this));
			this.collection.each(this.renderOrder, this);
			return this;
		},
		renderOrder: function(item) {
			if(item.get('record_id'))
			{
				var recordView = new RecordView({
            		model: item
	        	});
	        	$("#recordView").append(recordView.render().el);	
			}
			else
			{
				var pageNotFound = new PageNotFound();
				$("#pageRecord").html(pageNotFound.render().el);		
			}
	        return this;
		}
	});

	return ViewPage; 

});