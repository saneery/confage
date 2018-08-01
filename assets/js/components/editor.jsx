import React from "react";
import brace from 'brace';
import AceEditor from 'react-ace';
import 'brace/mode/json';
import 'brace/theme/github';


export default class Editor extends React.Component {
  constructor(props) {
    super(props);
    this.onChange = this.onChange.bind(this);
    this.onSave = this.onSave.bind(this);
    this.state = {app: this.props.app, content: "", saveActive: true};
  }

  componentDidMount() {
    $.get(
      `/api/apps/${this.state.app}/config`
    ).done(data => {
      this.setState({content: data.data})
    })
  }

  isValidJson(str) {
    try {
      JSON.parse(str);
    }
    catch(e) {
      return false;
    }
    return true;
  }

  onChange(newContent) {
    var saveable = this.isValidJson(newContent);
    this.setState({content: newContent, saveActive: saveable})
  }

  onSave() {
    if(this.isValidJson(this.state.content)) {
      $.post(
        `/api/apps/${this.state.app}/config`,
        {name: this.state.app, data: this.state.content}
      )
    } else {
      console.log("ivalid json")
    }
  }

  render() {
    return <div>
      <div className="btn-group">
        <button className="btn" onClick={this.props.close}>Back</button>
        <button className="btn btn-primary" onClick={this.onSave} disabled={!this.state.saveActive}>Save</button>
      </div>
      <h3>{this.state.app}</h3>
      <AceEditor
        mode="json"
        theme="github"
        onChange={this.onChange}
        value={this.state.content}
        editorProps={{$blockScrolling: true}}
      />
    </div>
  }
}