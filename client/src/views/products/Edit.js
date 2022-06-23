import PropTypes from 'prop-types';
import { forwardRef, useEffect, useRef, useState } from 'react';

// material-ui
import { useTheme, styled } from '@mui/material/styles';
import {
    Button,
    CardMedia,
    Chip,
    CircularProgress,
    Dialog,
    DialogActions,
    DialogContent,
    DialogTitle,
    Fab,
    Grid,
    Input,
    InputAdornment,
    InputLabel,
    MenuItem,
    Select,
    Slide,
    TextField,
    Typography
} from '@mui/material';

// project imports
import { gridSpacing } from 'store/constant';
import AnimateButton from 'ui-component/extended/AnimateButton';

// assets
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import CloseIcon from '@mui/icons-material/Close';

// styles
const ImageWrapper = styled('div')(({ theme }) => ({
    position: 'relative',
    overflow: 'hidden',
    borderRadius: '4px',
    cursor: 'pointer',
    width: 55,
    height: 55,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: theme.palette.background.default,
    '& > svg': {
        verticalAlign: 'sub',
        marginRight: 6
    }
}));

// animation
const Transition = forwardRef((props, ref) => <Slide direction="left" ref={ref} {...props} />);

const ITEM_HEIGHT = 48;
const ITEM_PADDING_TOP = 8;
const MenuProps = {
    PaperProps: {
        style: {
            maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
            width: 250
        }
    },
    chip: {
        margin: 2
    }
};

// tags list & style
const tagNames = ['Html', 'Scss', 'Js', 'React', 'Ionic', 'Angular', 'css', 'Php', 'View'];

function getStyles(name, personName, theme) {
    return {
        fontWeight: personName.indexOf(name) === -1 ? theme.typography.fontWeightRegular : theme.typography.fontWeightMedium
    };
}

// ==============================|| PRODUCT ADD DIALOG ||============================== //

const ProductEdit = ({ open, handleCloseDialog, data, tags }) => {
    const theme = useTheme();
    // handle category change dropdown
    const [currency, setCurrency] = useState('2');
    const handleSelectChange = (event) => {
        setCurrency(event?.target.value);
    };
    // set image upload progress
    const [progress, setProgress] = useState(0);
    const progressRef = useRef(() => {});
    useEffect(() => {
        progressRef.current = () => {
            if (progress > 100) {
                setProgress(0);
            } else {
                const diff = Math.random() * 10;
                setProgress(progress + diff);
            }
        };
    });

    useEffect(() => {
        const timer = setInterval(() => {
            progressRef.current();
        }, 500);

        return () => {
            clearInterval(timer);
        };
    }, []);

    // handle tag select
    const [personName, setPersonName] = useState([]);
    const handleTagSelectChange = (event) => {
        setPersonName(event?.target.value);
    };

    return (
        <Dialog
            open={open}
            TransitionComponent={Transition}
            keepMounted
            onClose={handleCloseDialog}
            sx={{
                '&>div:nth-of-type(3)': {
                    justifyContent: 'flex-end',
                    '&>div': {
                        m: 0,
                        borderRadius: '0px',
                        maxWidth: 450,
                        maxHeight: '100%'
                    }
                }
            }}
        >
            {open && (
                <>
                    <DialogTitle>Editer un Produit</DialogTitle>
                    <DialogContent>
                        <Grid container spacing={gridSpacing} sx={{ mt: 0.25 }}>
                            <Grid item xs={12}>
                                <TextField id="outlined-basic1" fullWidth label="Nom du Produit*" defaultValue={data.name} />
                            </Grid>
                            <Grid item xs={12}>
                                <TextField
                                    id="outlined-basic2"
                                    fullWidth
                                    multiline
                                    rows={3}
                                    label="Description"
                                    defaultValue={data.description}
                                />
                            </Grid>
                            <Grid item xs={12}>
                                <Select
                                    id="demo-multiple-chip"
                                    multiple
                                    fullWidth
                                    defaultValue={data.category}
                                    onChange={handleTagSelectChange}
                                    input={<Input id="select-multiple-chip" />}
                                    renderdefaultValue={(selected) => (
                                        <div>
                                            {typeof selected !== 'string' && selected.map((value) => <Chip key={value} label={value} />)}
                                        </div>
                                    )}
                                    MenuProps={MenuProps}
                                >
                                    {tags.map((name) => (
                                        <MenuItem key={name} defaultValue={data.category} style={getStyles(name, personName, theme)}>
                                            {name}
                                        </MenuItem>
                                    ))}
                                </Select>
                            </Grid>
                            <Grid item xs={12}>
                                <TextField id="outlined-basic3" fullWidth label="Reférence*" defaultValue="" />
                            </Grid>
                            <Grid item md={6} xs={12}>
                                <TextField
                                    label="Prix*"
                                    id="filled-start-adornment1"
                                    defaultValue={data.price}
                                    InputProps={{ startAdornment: <InputAdornment position="start">€</InputAdornment> }}
                                />
                            </Grid>
                            <Grid item md={6} xs={12}>
                                <TextField
                                    label="Réduction"
                                    id="filled-start-adornment2"
                                    defaultValue={data.discount}
                                    InputProps={{ startAdornment: <InputAdornment position="start">%</InputAdornment> }}
                                />
                            </Grid>
                            <Grid item md={6} xs={12}>
                                <TextField label="Quantité*" id="quantity" defaultValue={data.quantity} placeholder="0" />
                            </Grid>
                            <Grid item md={6} xs={12}>
                                <TextField label="Marque*" id="brand" defaultValue={data.brand} placeholder="Ex : Apple" />
                            </Grid>
                            <Grid item md={6} xs={12}>
                                <TextField
                                    defaultValue={data.weight}
                                    label="Poids"
                                    InputProps={{ endAdornment: <InputAdornment position="end">kg</InputAdornment> }}
                                />
                            </Grid>
                            <Grid item xs={12}>
                                <Grid container spacing={1}>
                                    <Grid item xs={12}>
                                        <Typography variant="subtitle1" align="left">
                                            Images du Produit*
                                        </Typography>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <div>
                                            <TextField type="file" id="file-upload" fullWidth label="Enter SKU" sx={{ display: 'none' }} />
                                            <InputLabel
                                                htmlFor="file-upload"
                                                sx={{
                                                    background: theme.palette.background.default,
                                                    py: 3.75,
                                                    px: 0,
                                                    textAlign: 'center',
                                                    borderRadius: '4px',
                                                    cursor: 'pointer',
                                                    mb: 3,
                                                    '& > svg': {
                                                        verticalAlign: 'sub',
                                                        mr: 0.5
                                                    }
                                                }}
                                            >
                                                <CloudUploadIcon /> Déposer vos images
                                            </InputLabel>
                                        </div>
                                    </Grid>
                                </Grid>
                            </Grid>
                            <Grid item xs={12}>
                                <Grid container spacing={1}>
                                    <Grid item xs={12}>
                                        <Typography variant="subtitle1" align="left">
                                            Tags
                                        </Typography>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <div>
                                            <Select
                                                id="demo-multiple-chip"
                                                multiple
                                                fullWidth
                                                defaultValue={personName}
                                                onChange={handleTagSelectChange}
                                                input={<Input id="select-multiple-chip" />}
                                                renderdefaultValue={(selected) => (
                                                    <div>
                                                        {typeof selected !== 'string' &&
                                                            selected.map((value) => <Chip key={value} label={value} />)}
                                                    </div>
                                                )}
                                                MenuProps={MenuProps}
                                            >
                                                {tagNames.map((name) => (
                                                    <MenuItem key={name} defaultValue={name} style={getStyles(name, personName, theme)}>
                                                        {name}
                                                    </MenuItem>
                                                ))}
                                            </Select>
                                        </div>
                                    </Grid>
                                </Grid>
                            </Grid>
                        </Grid>
                    </DialogContent>
                    <DialogActions>
                        <Button variant="text" color="error" onClick={handleCloseDialog}>
                            Fermer
                        </Button>
                        <AnimateButton>
                            <Button variant="contained">Créer</Button>
                        </AnimateButton>
                    </DialogActions>
                </>
            )}
        </Dialog>
    );
};

ProductEdit.propTypes = {
    open: PropTypes.bool,
    handleCloseDialog: PropTypes.func
};

export default ProductEdit;
