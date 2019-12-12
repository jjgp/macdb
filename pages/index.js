import React, { useEffect, useState } from 'react';
import { WindowClient } from '../model/macdb_grpc_web_pb';
import { WindowInfo } from '../model/macdb_pb';

const Index = () => {
  const [image, setImage] = useState(null);

  useEffect(() => {
    const client = new WindowClient('http://localhost:8080');
    const request = new WindowInfo();
    request.setName('iPhone 11 Pro Max — 13.2.2');

    const stream = client.capture(request, {});
    stream.on('data', response => {
      console.log('received image');
      const image = response.getImage();
      if (image) {
        setImage(`data:image/jpeg;base64,${image}`);
      }
    });

    stream.on('status', status => {
      console.log(status);
    });
  }, []);

  return image ? (
    <div>
      <img src={image} width='375' height='812' />
    </div>
  ) : null;
};

export default Index;
