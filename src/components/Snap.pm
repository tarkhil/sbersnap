<template>
  <div>
  <div v-for="message in messages">
  
  </div>
  </div>
  </template>
  
  <script>
  export default {
  data: function() {
      return {
	    messages: [],
	    currentStatus: 'ждем',
	    cookies: '',
	    running: false,
	      
	     },
	     name: "Snap",
	       
	     };
    </script>
      
      <!-- Add "scoped" attribute to limit CSS to this component only -->
      <style scoped>
      h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
