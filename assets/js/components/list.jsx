import React from "react";
import ReactDOM from "react-dom";

export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
    this.handleAdd = this.handleAdd.bind(this);
    this.state = { apps: [], new_app: "" };
  }

  componentDidMount() {
    $.get(
      "/api/apps"
    ).done(data => {
      this.setState({apps: data.data})
    });
  }

  handleChange(e) {
    this.setState({ new_app: e.target.value })
  }

  handleAdd(e) {
    e.preventDefault();
    if(this.state.new_app.length == 0) {
      return;
    }
    $.post("/api/apps/create", {
      name: this.state.new_app
    }).done(data => {
      this.state.apps.push(this.state.new_app);
      this.setState({ apps: $.unique(this.state.apps), new_app: "" });
    })
  }

  delete(e, name) {
    e.stopPropagation();
    $.ajax({
      url: `/api/apps/${name}`,
      type: 'DELETE'
    }).done(() => {
      var list = $.grep(this.state.apps, val => {
        console.log(name, val);
        return name != val;
      });
      console.log(list)
      this.setState({apps: list});
    })
  }

  render() {
    var list = $.map(
      this.state.apps,
      (name, index) => {
        return <a key={index} href="#" onClick={() => {this.props.selectApp(name)}} className="list-group-item list-group-item-action">
          {name}
          <span className="pull-right">
            <button type="button" className="btn btn-xs btn-link" onClick={(e) => {this.delete(e, name)}}>
              Delete
            </button>
          </span>
        </a>
      });
    return <div>
      <h3>APPS</h3>
      <div className="input-group">
        <input type="text" className="form-control" onChange={this.handleChange} value={this.state.new_app}/>
        <div className="input-group-btn">
          <button type="button" onClick={this.handleAdd} className="btn btn-primary">Add</button>
        </div>
      </div>
      <ul className="list-group list-group-flush">
        {list}
      </ul>
    </div>
  }
}