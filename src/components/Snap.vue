<template>
  <div>
    <div class="row">
      <div class="col-md-12">
        <p>
          Эта программа не делится данными ни с кем, кроме собственно Сбербанка
          Онлайн. Вы можете скачать ее с
          <a href="https://github.com/tarkhil/sbersnap">GitHub</a> и запустить у
          себя на компьютере.
        </p>
        <p>
          Чтобы воспользоваться программой, зайдите в Сбербанк Онлайн, откройте
          консоль разработчика, откройте информацию по любой карте и из запроса
          к list.do - скопируйте содержимое заголовка Cookie. Я даю слово, что у
          меня на серверер эта информация не сохранится нигде. Впрочем, если вы
          мне не верите, запустите весь код на доверенном сервере.
        </p>
        <p>
          Инструкции по запуску не прилагаются; если вы владеете Perl и JS, вы
          легко запустите все сами, если нет - то не сможете убедиться в
          безопасности кода
        </p>
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
          >{{ Format(part.Start, "dd/MM/yyyy") }} -
          {{ Format(part.End, "dd/MM/yyyy") }}</span
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
import { saveAs } from "file-saver";
import { json2csv } from "json-2-csv";

export default {
  components: {
    MonthPicker
  },
  data: function() {
    return {
      messages: [],
      csv: "",
      ops: [],
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
          const month = await axios.post("https://snap.over.ru/api/sber", {
            start: format(this.part.Start, "dd.MM.yyyy"),
            stop: format(this.part.End, "dd.MM.yyyy"),
            cookies: this.cookies
          });
          this.ops = this.ops.concat(month.data.operations);
          this.part.Start = add(this.part.Start, { months: 1 });
          this.part.End = add(this.part.Start, { months: 1 });
          stop = this.part.End >= this.date.End;
        }
        await json2csv(this.ops, (err, csv) => {
          if (err) {
            this.messages.push({
              text: "Ошибка преобразования: " + err,
              variant: "danger"
            });
          } else {
            saveAs(new Blob([csv]), "report.csv", {
              keys: [
                "date",
                "from",
                "to",
                "description",
                "stateHint",
                "op_amount",
                "op_currency",
                "commission_amount",
                "commission_currency"
              ]
            });
            this.messages.push({ text: "закончили", variant: "info" });
            this.ops = [];
          }
        });
      } catch (err) {
        console.error(err);
        this.messages.push({ text: err, variant: "danger" });
        this.ops = [];
      }
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
