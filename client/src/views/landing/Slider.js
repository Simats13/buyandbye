import PropTypes from 'prop-types';

// material-ui
import { styled } from '@mui/material/styles';
import { Box, Grid, Typography } from '@mui/material';

// third party
import Slider from 'react-slick';

// assets
import interfaceWeb from 'assets/images/landing/interfaceWeb.svg';
import interfaceStep from 'assets/images/landing/interfaceStep.svg';
import colorView from 'assets/images/landing/colorView.svg';

// styles

// =============================|| SLIDER ITEMS ||============================= //

const Item = ({ item }) => (
    <Grid container alignItems="center" justifyContent="center" spacing={3} textAlign="center">
        <Grid item xs={11}>
            <Box sx={{ position: 'relative' }}>
                <img src={item.image} alt="Berry" style={{ width: '100%', animation: '5s wings ease-in-out infinite' }} />
            </Box>
        </Grid>
        <Grid item xs={10}>
            <Grid container direction="column" alignItems="center" spacing={3} textAlign="center">
                <Grid item sm={12}>
                    <Typography variant="h4" component="div">
                        {item.title}
                    </Typography>
                </Grid>
                <Grid item sm={12}>
                    <Typography variant="body2">{item.content}</Typography>
                </Grid>
            </Grid>
        </Grid>
    </Grid>
);

Item.propTypes = {
    item: PropTypes.object.isRequired
};

// ==============================|| LANDING - SLIDER PAGE ||============================== //

const SliderPage = () => {
    const settings = {
        autoplay: true,
        arrows: false,
        dots: true,
        infinite: true,
        speed: 500,
        slidesToShow: 1,
        slidesToScroll: 1
    };

    const items = [
        {
            image: interfaceWeb,
            title: 'Une interface simple et intuitive',
            content:
                "L'interface a été conçu afin de coller aux besoins réels des entreprises, mais surtout d'une simplicité à rude épreuve."
        },
        {
            image: interfaceStep,
            title: 'Gestion de votre page',
            content: 'Gérer votre entreprise directement depuis le panel qui lui est dédié.'
        },
        {
            image: colorView,
            title: 'Personnalisation',
            content: 'Personnalisez votre boutique aux couleurs de votre entreprise et ainsi vous démarquer des autres !'
        }
    ];

    return (
        <Slider {...settings}>
            {items.map((item, index) => (
                <Item key={index} item={item} />
            ))}
        </Slider>
    );
};

export default SliderPage;
