var token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'


var app = new Vue({
    el: '#app',
    data:function() {
        return {
            campers: []
        }

    },
    mounted: function () {
     var fetchedData= this.fetchData();
     this.campers.push.apply(this.campers,fetchedData);
     console.log("mounting happens here");
     console.log(fetchedData);

    },

    methods: {
        fetchData: function() {
	 var res=this;
         axios.get("api/campers").then(function(response){
	  	res.campers=response.data;
		console.log(res);
	});
	
	
        }

    }
});
