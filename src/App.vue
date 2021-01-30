<template>
  <div id="app">
    <Snap />
  </div>
</template>

<script>
import Snap from "./components/Snap.vue";

export default {
  name: "App",
  components: {
    Snap
  }
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
