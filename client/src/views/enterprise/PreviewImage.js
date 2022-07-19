import { CloudUploadOutlined } from '@mui/icons-material';
import { CardMedia, Typography } from '@mui/material';
import useConfig from 'hooks/useConfig';
import React, { Component } from 'react';
import MainCard from 'ui-component/cards/MainCard';

const PreviewImage = ({ files }) => {
    const [preview, setPreview] = React.useState(null);
    const { borderRadius } = useConfig();
    const reader = new FileReader();
    reader.readAsDataURL(files);
    reader.onload = () => {
        setPreview(reader.result);
    };
    return preview ? (
        <>
            {preview ? (
                <MainCard content={false} border={false} boxShadow style={{ cursor: 'pointer' }}>
                    <CardMedia
                        component="img"
                        image={preview}
                        height="150"
                        style={{ filter: 'blur(5px)' }}
                        title="Banniere Entreprise"
                        sx={{ borderRadius: `${borderRadius}px`, overflow: 'hidden' }}
                    />
                    <Typography
                        align="center"
                        variant="h3"
                        style={{
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            position: 'absolute',
                            top: '50%',
                            width: '100%',
                            textAlign: 'center',
                            // color: 'linear-gradient(225deg, #FF7643 0%, #FF4B33 100%)',
                            fontWeight: 'bold'
                        }}
                        gutterBottom
                    >
                        <CloudUploadOutlined
                            fontSize="large"
                            color="primary"
                            sx={{ color: 'linear-gradient(225deg, #FF7643 0%, #FF4B33 100%)' }}
                        />
                    </Typography>
                </MainCard>
            ) : (
                'Chargement'
            )}
        </>
    ) : (
        'Chargement'
    );
};

export default PreviewImage;
