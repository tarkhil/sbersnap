<template>
  <div>
    <div class="row">
      <div class="col-md-12">
        Эта программа не делится данными ни с кем, кроме собственно Сбербанка
        Онлайн. Вы можете скачать ее с (тут ссылка) и запустить у себя на
        компьютере
      </div>
    </div>
    <div v-for="(message, index) in messages" :key="index">
      <b-alert
        show
        @dismissed="alertDismissed(index)"
        :variant="message.variant"
        dismissible
        >{{ message.text }}...</b-alert
      >
    </div>
    <div class="row">
      <div class="col-md-12">
        Статус: {{ currentStatus }}
        <span v-if="running"
          >{{ Format(date.Start, "dd/MM/yyyy") }} -
          {{ Format(date.End, "dd/MM/yyyy") }}</span
        >
      </div>
    </div>
    <b-form>
      <b-form-group label="Период">
        <div class="row">
          <div class="col-md-6">
            <month-picker @change="setStart"></month-picker>
          </div>
          <div class="col-md-6">
            <month-picker @change="setEnd"></month-picker>
          </div>
        </div>
      </b-form-group>
      <b-form-group label="Cookie">
        <b-form-textarea
          v-model="cookies"
          placeholder="Cookie..."
          rows="6"
          max-rows="10"
        ></b-form-textarea>
      </b-form-group>
      <b-form-group
        ><b-button
          :disabled="cookies === ''"
          variant="primary"
          @click="startLoading"
          >Начали</b-button
        ></b-form-group
      >
    </b-form>
  </div>
</template>

<script>
import axios from "axios";
import Vue from "vue";
import { MonthPicker } from "vue-month-picker";
import { MonthPickerInput } from "vue-month-picker";
Vue.use(MonthPicker);
Vue.use(MonthPickerInput);
import { format } from "date-fns";
import add from "date-fns/add";

export default {
  components: {
    MonthPicker
  },
  data: function() {
    return {
      messages: [],
      csv: "",
      currentStatus: "ждем",
      cookies: "",
      running: false,
      complete: false,
      part: { Start: null, End: null },
      date: { Start: null, End: null }
    };
  },
  name: "Snap",
  methods: {
    Format(d, f) {
      return format(d, f);
    },
    setStart(date) {
      this.setDate(date, "Start");
    },
    setEnd(date) {
      this.setDate(date, "End");
    },
    setDate(date, pos) {
      if (pos === "Start") {
        this.date.Start = date.from;
      } else if (pos === "End") {
        this.date.End = date.to;
      } else {
        throw `Bad position ${pos}`;
      }
    },
    alertDismissed(i) {
      this.messages.splice(i, 1);
    },
    start() {
      this.currentStatus = "работаем";
      this.part.Start = this.date.Start;
      this.part.End = add(this.part.Start, { months: 1 });
    },
    async startLoading() {
      this.currentStatus = "работаем";
      this.part.Start = this.date.Start;
      this.part.End = add(this.part.Start, { months: 1 });
      let stop = false;
      this.running = true;
      try {
        while (!stop) {
          console.log(format(this.part.Start, "dd.MM.yyyy"));
          const month = await axios.post(
            "https://node1.online.sberbank.ru/PhizIC/clientapi/private/payments/list.do?from=" +
              format(this.part.Start, "dd.MM.yyyy") +
              "&to=" +
              format(this.part.End, "dd.MM.yyyy") +
              "&paginationSize=2000&paginationOffset=0&includeUfs=true&showExternal=true",
            {},
            {
              withCredentials: true,
              headers: {
                Cookie: this.cookies,
                Accept: "application/json, text/plain, */*",
                "Accept-Encoding": "gzip, deflate, br",
                "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
                "Cache-Control": "no-cache",
                "Content-Type": "application/json",
                DNT: "1",
                Origin: "https://front.node1.online.sberbank.ru",
                Pragma: "no-cache",
                Referer: "https://front.node1.online.sberbank.ru/",
                "Sec-Fetch-Dest": "empty",
                "Sec-Fetch-Mode": "cors",
                "Sec-Fetch-Site": "same-site"
              }
            }
          );
          console.log(month);
          this.part.Start = add(this.part.Start, { months: 1 });
          this.part.End = add(this.part.Start, { months: 1 });
          stop = this.part.End >= this.date.End;
        }
        // Тут выгрузить файл
      } catch (err) {
        console.error(err);
        this.messages.push({ text: err, variant: "danger" });
      }
      this.messages.push({ text: "закончили", variant: "info" });
      this.currentStatus = "ждем";
      this.running = false;
    }
  }
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
