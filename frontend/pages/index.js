import React, { useCallback, useEffect, useState } from 'react';
import { WindowClient } from '../model/macdb_grpc_web_pb';
import { WindowInfo, WindowPoint } from '../model/macdb_pb';

const client = new WindowClient('http://localhost:8080');

const Index = () => {
  const [image, setImage] = useState(null);
  const onClick = useCallback(e => {
    const windoInfo = new WindowInfo();
    windoInfo.setName('iPhone 11 Pro Max — 13.3');
    const request = new WindowPoint();
    request.setWindowinfo(windoInfo);
    request.setX(e.nativeEvent.offsetX);
    request.setY(e.nativeEvent.offsetY);

    client.touch(request, {}, () => { });
  });

  useEffect(() => {
    const request = new WindowInfo();
    request.setName('iPhone 11 Pro Max — 13.3');

    const stream = client.capture(request, {});
    stream.on('data', response => {
      setImage(response.getImage() && `data:image/jpeg;base64,${response.getImage()}`);
    });

    stream.on('status', status => {
      console.log(status);
    });
  }, []);

  return image ? (
    <div>
      <img onClick={onClick} src={image} />
    </div>
  ) : null;
};

export default Index;
