<script>

export default {
  data() {
    return {
      directoryList: {},
      view: false,
      searchInput: '',
      isOptedIn: false,
      currentPage: 1,
      pagesTotal: 1,
    }
  },
  mounted() {
    let self = this;
    window.addEventListener('message', this.onMessage);
    window.addEventListener('keyup', function (e) {
      if (e.key == "Escape") {
        self.fireEvent('closeAll')
      }
    });
  },
  destroyed() {
    window.removeEventListener('message')
    window.removeEventListener('keyup')
  },
  methods: {
    onMessage(event) {
      if (event.data.type === 'view') {
        this.directoryList = event.data.directoryList
        this.view = true
        this.isOptedIn = event.data.isOptedIn
        console.log(event.data.isOptedIn)
      }
      if (event.data.type === 'updateList') {
        this.directoryList = event.data.directoryList
        this.currentPage = event.data.currentPage,
        this.pagesTotal = event.data.pagesTotal
      }
      if (event.data.type === 'updateOpted') {
        this.isOptedIn = event.data.isOptedIn
      }
      if (event.data.type === 'close') {
        this.view = false;
        this.directoryList = {};
        this.searchInput = '';
      }

    },
    fireEvent(eve, opts = {}) {
      fetch(`https://${GetParentResourceName()}/` + eve, {
        method: 'POST',
        body: JSON.stringify(opts)
      })
    },
    searchUp(){
      if(this.searchInput.length >= 2) {
        this.fireEvent('searchDir', {
          input: this.searchInput,
          requestedPage: 1,
        })
      }
      if(this.searchInput.length == 0) {
        this.fireEvent('clear')
      }
    },
    nextPage(){
      if(this.searchInput.length >= 2) {
        this.fireEvent('searchDir', {
          input: this.searchInput,
          requestedPage: this.currentPage + 1,
        })
      }else{
        this.fireEvent('searchDir', {
          input: "",
          requestedPage: this.currentPage + 1,
        })
      }
    },
    previousPage(){
      if(this.searchInput.length >= 2) {
        this.fireEvent('searchDir', {
          input: this.searchInput,
          requestedPage: this.currentPage - 1,
        })
      }else{
        this.fireEvent('searchDir', {
          input: "",
          requestedPage: this.currentPage - 1,
        })
      }
    },
    copyToClipboard(textToCopy){
      // navigator.clipboard.writeText(textToCopy);

      let copyTextInputElement = document.querySelector("#copiable-text");
      copyTextInputElement.value = textToCopy;
      copyTextInputElement.select();

      try {
        if (document.execCommand("copy", false)) {
          this.fireEvent('copied', {})
        }
      } catch (e) {
        console.error("error caught:", e);
      }
    }
  }
};

</script>

<template>
  <header>
  </header>

  <main>

    <!-- VIEW DIRECTORY -->

    <div style="position: absolute; left:-9000px; top:-9000px;">
      <input id="copiable-text" />
    </div>

    <div class="wrapper ma-5" v-if="view">

      <div class="main-container">

        <div class="close-button float-right ma-0 pa-0" @click="fireEvent('closeView')">
          <div class="closeButtonImg-container">
            <img id="closeButtonImg" />
          </div>
          <v-btn class="close-button-text" variant="text">CLOSE</v-btn>
        </div>

        <div class="view-directory">

          <div class="directory-spacer"></div>

          

          <v-container id="directory-container" class="w-auto ml-2 mr-2">
            <v-row>
              <v-col cols="12">
                <div class="directoryList">
                  
                  <v-table height="550px">
                    <thead>
                      <tr>
                        <th class="text-left" width="40%">
                          NAME
                        </th>
                        <th class="text-left" width="60%">
                          TELEGRAM NUMBER
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="item in directoryList"
                        :key="(item.full_char_name + item.telegram)"
                      >
                        <td>{{ item.full_char_name }}</td>
                        <td class="telegram-number pl-0">
                          <v-btn @click="copyToClipboard(item.telegram)" class="button-telegram-number" variant="text">{{ item.telegram }}</v-btn>
                        </td>
                      </tr>
                    </tbody>
                  </v-table>
                
                </div>
              </v-col>
            </v-row>
          

            <div id="footer-container" class="w-auto">
              <v-row class="d-flex justify-space-between">
                <div class="col-searchBoxTextField ml-2 mt-3">
                  <v-text-field id="searchBoxTextField" single-line v-model="searchInput" @input="searchUp" class="search-box text-field" label="search">
                  </v-text-field>
                </div>

                <div id="previous-button-container" :class="{ invisible: !(this.currentPage > 1) }" class="button-page-container d-flex align-center align-self-center mb-2">
                  <div class="button-page d-flex">
                    <div @click="previousPage()" class="button-page-text align-center align-self-center ma-auto pb-1">
                      PREVIOUS
                    </div>
                  </div>
                </div>

                <div id="next-button-container" :class="{ invisible: !(this.currentPage < this.pagesTotal) }" class="button-page-container d-flex align-center align-self-center mb-2">
                  <div class="button-page d-flex">
                    <div @click="nextPage()" class="button-page-text align-center align-self-center ma-auto pb-1">
                      NEXT
                    </div>
                  </div>
                </div>

                <div class="opted-container d-flex align-center">
                  <div v-if="this.isOptedIn == true" class="d-flex align-center mb-3 mr-2">
                    <span class="mr-2">Opted In</span>
                    <img class="optedInButtonImg" @click="fireEvent('setOpted', {opted: false}); this.isOptedIn = false; searchUp();" />
                  </div>
                  <div v-if="this.isOptedIn == false" class="d-flex align-center mb-3 mr-2">
                    <span class="mr-2">Opted Out</span>
                    <img class="optedOutButtonImg" @click="fireEvent('setOpted', {opted: true}); this.isOptedIn = true; searchUp();" />
                  </div>
                </div>
              </v-row>
              

            </div>

          </v-container>
        </div>
      </div>
    </div>

  </main>
</template>

<style scoped>

</style>
