import List from "./list";
import Editor from "./editor";

class App extends React.Component {
  constructor() {
    super();
    this.state = { selectedApp: false }
  }

  onClose() {
    this.setState({selectedApp: false})
  }

  onSelect(name) {
    this.setState({selectedApp: name})
  }
  render() {
    var app = this.state.selectedApp;
    if(app) {
      return <Editor app={app} close={this.onClose.bind(this)}/>
    }
    else {
      return <List selectApp={this.onSelect.bind(this)}/>
    }
  }
}

if(document.getElementById('main')) {
  ReactDOM.render((
    <App/>
  ), document.getElementById('main'));
}